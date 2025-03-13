{ pkgs
, config
, username
, lib
, inputs
, outputs
, options
, ...
}:
let
  inherit (pkgs.stdenv) isDarwin isLinux;

  # list of keys which can be used for key-based SSH authentication when logging in to another system
  # key is the hostname, value is the key
  #
  # these are unique per-system, to track which system is logging in to a particular server
  keys = import ../keys;

  # ssh key used for signing Git commits
  # this key is shared among all systems the user can log in to
  # as it does not matter which device the git commit is being signed by (more interested in which *user* is signing)
  gitSigningKey = if lib.hasAttr username keys.signing then lib.getAttr username keys.signing else null;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.hmModules.nix-index

    ./base # base config for programs

    ./_mixins/features
    ./_mixins/scripts
    ./_mixins/services
    ./_mixins/users
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  # new Agenix configuration which is *user-specific* (DISTINCT from the system Agenix config)
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ] ++ options.age.identityPaths.default;
  };

  # Home Manager configuration/ options
  home = {
    inherit username;
    # inherit stateVersion;
    stateVersion = "22.11";
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

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

      ".ssh/allowed_signers" = {
        text = "${config.programs.git.userEmail} ${gitSigningKey}";
        enable = gitSigningKey != null;
      };
    };
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
}
