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
    ./neovim.nix
    ./nushell
    ./ripgrep.nix # better grep
    ./ssh.nix
    ./starship.nix
    ./wezterm
    ./zellij
  ];

  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them

    age # encryption
    bc # calculator
    croc # file sharing
    delta # git and diff viewer
    diffsitter # better diff
    dog # better dig
    httpie # better curl
    hub # Git wrapper that has better Github support
    hyperfine # command-line benchmarking
    just # command runner
    lazygit # git with TUI
    ncdu # TUI disk usage
    rclone
    restic
    rsync
    silver-searcher
    tldr # cheatsheets in terminal

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
    nodejs
    rustc
    shellcheck
    zigpkgs.master

    cachix
    hydra-check
    hydra-check # check hydra for build status of a package
    nh # Nice wrapper for NixOS and HM
    nix-init # generate nix package from a URL
    nix-output-monitor
    nix-prefetch
    nix-tree
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
        store_failed = false;
        sync = {
          records = true;
        };
      };
    };
    lazygit.enable = true;
    home-manager.enable = true;
    nix-index.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };
}
