# home manager config
{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  imports = [
    ./apps/alacritty.nix
    ./apps/bash.nix
    ./apps/bat.nix
    ./apps/bottom.nix
    ./apps/direnv.nix
    ./apps/fish.nix
    ./apps/fzf.nix
    ./apps/git.nix
    ./apps/lsd.nix
    ./apps/neovim.nix
    ./apps/nushell
    ./apps/ssh.nix
    ./apps/zellij.nix
    ./apps/zsh.nix
  ];

  home = {
    username = "joseph";
    homeDirectory = if isDarwin then "/Users/joseph" else "/home/joseph";
    packages = with pkgs; [
      # custom packages
      recyclarr

      # nix
      cachix
      nix-prefetch
      nix-update
      nixpkgs-fmt
      nixpkgs-review
      nil

      # GPT
      llamaPackages.llama-cpp # from llama-cpp overlay
      python311Packages.huggingface-hub

      # misc
      age
      bashInteractive
      cmake
      croc # file sharing
      exiftool
      fd
      gh
      hugo
      httpie
      just
      jq
      less
      ncdu
      python311
      rclone
      restic
      rsync
      silver-searcher
      spoof-mac
      tldr # cheatsheets in terminal
      yt-dlp
      ffmpeg_6

      # languages
      nim
      nimble # package manager for nim
      nodejs
      cargo
      rustc
      zigpkgs.master

      # python
      python311Packages.poetry-core
    ];
    stateVersion = "22.11";
    shellAliases = {
      top = "btm";
      copy = "rsync --archive --verbose --human-readable --partial --progress --modify-window=1"; # copy <source> <destination>
      cat = "bat --paging=never --style=plain,header";
    };
  };

  programs = {
    atuin.enable = true;
    gitui.enable = true;
    lazygit.enable = true;
    home-manager.enable = true;
    ripgrep.enable = true;
    starship = {
      enable = true;
      settings = {
        command_timeout = 800;
      };
    };
    zoxide.enable = true;
  };

  programs.starship.settings = {
    line_break = {
      disabled = true;
    };
  };

  xdg = {
    # todo: look into this option more
    enable = false;
  };
}
