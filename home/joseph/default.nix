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
    ./apps/ssh.nix
    ./apps/zellij.nix
    ./apps/zsh.nix
  ];

  home = {
    packages =
      lib.attrValues {
        inherit
          (pkgs)
          # useful rust CLI tools

          fd
          ripgrep
          # misc

          age
          alejandra
          bash
          exiftool
          hugo
          just
          jq
          ncdu
          python311
          rclone
          restic
          cachix
          recyclarr
          spoof-mac
          # languages

          nodejs
          cargo
          rustc
          rnix-lsp
          ;
      }
      ++ [
        pkgs.python311Packages.poetry-core
        pkgs.zigpkgs.master
      ];
    stateVersion = "22.11";
  };

  programs = {
    home-manager.enable = true;
    zoxide.enable = true;
  };

  xdg = {
    # todo: look into this option more
    enable = false;
  };
}
