{ config
, osConfig
, lib
, pkgs
, ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  _1passEnabled = (osConfig ? homebrew && lib.elem "1password-cli" (builtins.map (item: item.name) osConfig.homebrew.casks))
    || (osConfig.programs ? _1password && osConfig.programs._1password.enable);
in
{
  imports = [ ];

  programs = {
    gh = {
      enable = true;
      extensions = [ ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    git = {
      userEmail = "1269177+josephst@users.noreply.github.com";
      userName = "Joseph Stahl";
      signing = {
        signByDefault = true;
        format = "ssh";
      };
      extraConfig = {
        gpg = {
          ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
        };
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-usersigningKey
        user.signingKey = "key::${config.myHomeConfig.keys.signing.joseph}";
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

  # enable 1password cli plugins
  xdg.configFile."op/plugins.sh" = {
    enable = _1passEnabled;
    text = ''
      export OP_PLUGIN_ALIASES_SOURCED=1
      alias gh="op plugin run -- gh"
    '';
  };
  programs.fish.interactiveShellInit = ''
    # source 1password-cli plugins
    if test -e ~/.config/op/plugins.sh
      source ~/.config/op/plugins.sh
    end
  '';
}
