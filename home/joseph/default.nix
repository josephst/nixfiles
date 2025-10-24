{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  _1passEnabled =
    (
      osConfig ? homebrew
      && lib.elem "1password-cli" (builtins.map (item: item.name) osConfig.homebrew.casks)
    )
    || (osConfig.programs ? _1password && osConfig.programs._1password.enable);

  gitSigningKey =
    if osConfig.myConfig.keys != null && lib.hasAttr "joseph" osConfig.myConfig.keys.signing then
      lib.getAttr "joseph" osConfig.myConfig.keys.signing
    else
      null;
in
{
  imports = [
    ../common
    ./base
    ./myHomeConfig.nix
  ];

  home = {
    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      EDITOR = "hx";
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      MANROFFOPT = "-c";
      VISUAL = "micro";
      SUDO_EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
    };
    shellAliases = {
      dig = "dog";
      copy = "rsync --archive --verbose --human-readable --partial --progress --modify-window=1"; # copy <source> <destination>
      external-ip = "dog +short myip.opendns.com @resolver1.opendns.com";
    };

    file = {
      # link nixpkgs-manual for quick reference
      "Documents/nixpkgs-manual.html".source = "${pkgs.nixpkgs-manual}/share/doc/nixpkgs/manual.html";

      ".ssh/allowed_signers" =
        lib.mkIf (gitSigningKey != null && config.programs.git.settings.user.email != null)
          {
            text = "${config.programs.git.settings.user.email} ${gitSigningKey}";
          };
    };
  };

  programs = {
    gh = {
      enable = true;
      extensions = [ ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };

  # auth with github is managed by 1password on mac (instead of reading gh/hosts.yml)
  age = {
    secrets = lib.mkIf isLinux {
      "gh/hosts.yml" = {
        file = ./secrets/gh_hosts.yml.age;
        path = "${config.xdg.configHome}/gh/hosts.yml";
      };
    };
  };

  xdg.configFile = {
    # enable 1password cli plugins
    "op/plugins.sh" = {
      enable = _1passEnabled;
      text = ''
        export OP_PLUGIN_ALIASES_SOURCED=1
        alias gh="op plugin run -- gh"
      '';
    };
    "ghostty/config".text = ''
      command = "${pkgs.fish}/bin/fish"

      theme = dark:Catppuccin Frappe,light:Catppuccin Latte
      keybind = shift+enter=text:\n
    '';
  };

  programs.fish.interactiveShellInit = ''
    # source 1password-cli plugins
    if test -e ~/.config/op/plugins.sh
      source ~/.config/op/plugins.sh
    end

    set -g SHELL ${pkgs.fish}/bin/fish

    # TODO: remove when https://github.com/atuinsh/atuin/issues/2803 is fixed
    # ${pkgs.atuin}/bin/atuin init fish | sed 's/-k up/up/' | source
  '';
}
