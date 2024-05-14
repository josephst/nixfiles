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
    ./jq.nix # JSON pretty printer
    ./neovim.nix
    ./nushell
    ./ripgrep.nix # better grep
    ./ssh.nix
    ./starship.nix
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
    hyperfine # command-line benchmarking
    just # command runner
    lazygit # git with TUI
    ncdu # TUI disk usage
    tldr # cheatsheets in terminal
    rclone
    restic
    rsync

    # development
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
    zigpkgs.master

    # llm
    llamaPackages.llama-cpp # from llama-cpp overlay
    python3Packages.huggingface-hub

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
    atuin.enable = true;
    lazygit.enable = true;
    home-manager.enable = true;
    zoxide.enable = true;
  };
}
