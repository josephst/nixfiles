{ pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  imports = [
    ./aider
    ./bash.nix
    ./bat.nix
    ./bottom.nix # system viewer
    ./direnv.nix
    ./eza.nix # better ls
    ./fd.nix # better find
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./helix.nix
    ./nushell
    ./ssh.nix
    ./starship.nix
    ./wezterm
    ./zellij
  ];

  home.packages =
    with pkgs;
    [
      age # encryption
      agenix # age secrets
      bc # calculator
      # claude-code # claude code # install w/ NPM
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
      httpie # better curl
      hub # Git wrapper that has better Github support
      hugo # static website builder
      hyperfine # command-line benchmarking
      ipfetch # IP info
      just # command runner
      lazygit # git with TUI
      marp-cli # markdown presentation
      ncdu # TUI disk usage
      nodejs
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
    ]
    ++ lib.optionals isLinux [
      iw # terminal wifi info
      pciutils # PCI info
      s-tui # stress test
      usbutils # USB info
    ]
    ++ lib.optionals isDarwin [
      nh # nix client (on nixos, this is a module)
      coreutils # macOS coreutils
    ];

  programs = {
    atuin = {
      enable = true;
      settings = {
        store_failed = true;
        sync = {
          records = true;
        };
      };
    };
    lazygit.enable = true;
    home-manager.enable = true;
    jq.enable = true;
    micro = {
      enable = true;
      settings = {
        autosu = true;
        diffgutter = true;
        paste = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
      };
    };
    ripgrep.enable = true;
    nix-index.enable = true;
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    zoxide.enable = true;
    zsh.enable = true;
  };
}
