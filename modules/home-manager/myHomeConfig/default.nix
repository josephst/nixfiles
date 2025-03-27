{ inputs, config, lib, pkgs, options, ... }:

let
  inherit (pkgs.stdenv) isDarwin isLinux;

  cfg = config.myHomeConfig;
  gitSigningKey = if lib.hasAttr cfg.username cfg.keys.signing then lib.getAttr cfg.username cfg.keys.signing else null;

  homeDirectory =
    if isDarwin then
      "/Users/${cfg.username}"
    else
      "/home/${cfg.username}";
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.hmModules.nix-index
    inputs._1password-shell-plugins.hmModules.default

    ./common
    ./scripts
    ./llm.nix
  ];

  options.myHomeConfig = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "joseph";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "24.11";
      description = ''
        home-manager stateVersion, should be kept the same or *very carefully* updated
        after reading release notes.
      '';
    };

    keys = lib.mkOption {
      # TODO: eventually move this to a submodule that can check the attributes
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "SSH keys for users on this system";
    };
  };

  config = {
    home = {
      inherit (cfg) username;
      inherit (cfg) stateVersion;
      inherit homeDirectory;

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

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    };

    # new Agenix configuration which is *user-specific* (DISTINCT from the system Agenix config)
    age = {
      identityPaths = [ "${homeDirectory}/.ssh/agenix" ] ++ options.age.identityPaths.default;
    };
    xdg = {
      enable = true;
      userDirs = {
        enable = isLinux;
        createDirectories = true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        };
      };

      configFile = {
        "ghostty/config".text = ''
          command = "${pkgs.fish}/bin/fish -l"

          theme = dark:catppuccin-frappe,light:catppuccin-latte
        '';
      };
    };
  };
}
