{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./bottom.nix # system viewer
    ./direnv.nix
    ./eza.nix # better ls
    ./fd.nix # better find
    ./fish.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./helix.nix
    ./jq.nix # JSON pretty printer
    ./neovim
    ./nushell
    ./ripgrep.nix # better grep
    ./ssh.nix
    ./starship.nix
    ./wezterm
    ./zellij
  ];

  home.packages = with pkgs; [
    age # encryption
    bc # calculator
    croc # file sharing
    delta # git and diff viewer
    diffsitter # better diff
    dogdns # better dig
    httpie # better curl
    hub # Git wrapper that has better Github support
    hyperfine # command-line benchmarking
    just # command runner
    lazygit # git with TUI
    ncdu # TUI disk usage
    python3
    rclone
    restic
    rsync
    tldr # cheatsheets in terminal
    typst # latex alternative for typesetting docs

    # development
    gh-dash
    hugo

    # media
    ffmpeg
    recyclarr # sync settings to -arr apps
    yt-dlp

    # languages
    cargo
    nim
    nimble # package manager for nim
    nixpkgs-manual # always handy to have documentation available
    nodejs
    rustc
    shellcheck
    zigpkgs.master

    cachix
    comma # Install and run programs by sticking a , before them
    hydra-check # check hydra for build status of a package
    nix-init # generate nix package from a URL
    nix-inspect
    nix-output-monitor
    nix-update
    nixd # Nix LSP
    nixfmt-rfc-style # nix formatter
    nixpkgs-hammering
    nixpkgs-review
    nurl # generate nix fetcher expression from a URL + revision
    nvd # differ
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
    thefuck.enable = true;
    lazygit.enable = true;
    home-manager.enable = true;
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
