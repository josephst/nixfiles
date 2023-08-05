# home manager config
{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  imports = [
    ./apps/alacritty.nix
    ./apps/bash.nix
    ./apps/bat.nix
    ./apps/bottom.nix
    ./apps/direnv.nix
    ./apps/exa.nix
    ./apps/fish.nix
    ./apps/fzf.nix
    ./apps/git.nix
    ./apps/neovim.nix
    ./apps/nushell
    ./apps/ssh.nix
    ./apps/zellij.nix
    ./apps/zsh.nix
  ];

  home = {
    username = "joseph";
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/joseph"
      else "/home/joseph";
    packages = with pkgs; [
      # custom packages
      recyclarr

      # nix
      alejandra
      cachix
      nixpkgs-fmt
      nix-prefetch
      rnix-lsp

      # misc
      age
      bashInteractive
      exiftool
      fd
      hugo
      httpie
      just
      jq
      less
      ncdu
      python311
      rclone
      restic
      silver-searcher
      spoof-mac
      tldr

      # languages
      nodejs
      cargo
      rustc
      zigpkgs.master

      # python
      python311Packages.poetry-core
    ];
    stateVersion = "22.11";
    shellAliases = {
      top = "${pkgs.bottom}/bin/btm";
      cat = "${pkgs.bat}/bin/bat --paging=never --style=plain,header";
    };
  };

  programs = {
    gitui.enable = true;
    lazygit.enable = true;
    home-manager.enable = true;
    ripgrep.enable = true;
    starship.enable = true;
    zoxide.enable = true;
  };

  xdg = {
    # todo: look into this option more
    enable = false;
  };
}
