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

  gitSigningKey = if lib.hasAttr "joseph" config.myHomeConfig.keys.signing then lib.getAttr "joseph" config.myHomeConfig.keys.signing else null;
in
{
  imports = [
    ./base
  ];

  home = {
    sessionVariables = {
      EDITOR = "micro";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = "-c";
      PAGER = "bat";
      VISUAL = "micro";
      SUDO_EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
    };
    shellAliases = {
      dig = "dog";
      copy = "rsync --archive --verbose --human-readable --partial --progress --modify-window=1"; # copy <source> <destination>
      external-ip = "dog +short myip.opendns.com @resolver1.opendns.com";
    };
    packages = with pkgs; [
      age # encryption
      agenix # age secrets
      bc # calculator
      comma # run commands by prefacing with comma
      cpufetch # CPU info
      croc # file sharing
      cyme # modern lsusb
      delta # git and diff viewer
      diffsitter # better diff
      dogdns # better dig
      dua # modern du
      duf # modern df
      fd # find
      gh-dash # github dashboard
      httpie # better curl
      hub # Git wrapper that has better Github support
      hugo # static website builder
      hyperfine # command-line benchmarking
      ipfetch # IP info
      just # command runner
      lazygit # git with TUI
      marp-cli # markdown presentation
      ncdu # TUI disk usage
      nixd # Nix LSP
      nixfmt-rfc-style # nix formatter
      nixpkgs-hammering # nixpkgs linter
      nixpkgs-review # review PRs
      nix-prefetch-scripts # nix code fetcher
      nix-update # update nixpkgs
      nurl # nix url fetcher
      procs # modern ps
      speedtest-go # speedtest CLI
      python3 # python
      rclone # syncing
      restic # backup
      rsync # syncing
      tldr # cheatsheets in terminal
      typst # latex alternative for typesetting docs
      yt-dlp # youtube-dl
    ] ++ lib.optionals isLinux [
      iw # terminal wifi info
      pciutils # PCI info
      s-tui # stress test
      usbutils # USB info
    ] ++ lib.optionals isDarwin [
      nh
      coreutils # macOS coreutils
    ];
    file = {
      # link nixpkgs-manual for quick reference
      "Documents/nixpkgs-manual.html".source = "${pkgs.nixpkgs-manual}/share/doc/nixpkgs/manual.html";

      ".ssh/allowed_signers" = lib.mkIf (gitSigningKey != null && config.programs.git.userEmail != null) {
        text = "${config.programs.git.userEmail} ${gitSigningKey}";
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
    git = {
      userEmail = "1269177+josephst@users.noreply.github.com";
      userName = "Joseph Stahl";
      signing = {
        signByDefault = true;
        format = "ssh";
        signer = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-usersigningKey
        key = "key::${config.myHomeConfig.keys.signing.joseph}";
      };
      extraConfig = {
        gpg = {
          ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
        };
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
      command = "bash -l -c fish"

      theme = dark:catppuccin-frappe,light:catppuccin-latte
    '';
  };


  programs.fish.interactiveShellInit = ''
    # source 1password-cli plugins
    if test -e ~/.config/op/plugins.sh
      source ~/.config/op/plugins.sh
    end
  '';
}
