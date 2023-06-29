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
    packages =
      lib.attrValues {
        inherit
          (pkgs)
          # useful rust CLI tools

          fd
          ripgrep
          # custom packages

          recyclarr
          # nix

          alejandra
          cachix
          nixpkgs-fmt
          rnix-lsp
          # misc

          age
          bashInteractive
          exiftool
          hugo
          httpie
          just
          jq
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
          ;
      }
      ++ [
        pkgs.python311Packages.poetry-core
        pkgs.zigpkgs.master
      ];
    stateVersion = "22.11";
    shellAliases = {
      top = "${pkgs.bottom}/bin/btm";
      cat = "${pkgs.bat}/bin/bat --paging=never --style=plain,header";
    };
  };

  programs = {
    gitui.enable = true;
    home-manager.enable = true;
    starship.enable = true;
    zoxide.enable = true;
  };

  xdg = {
    # todo: look into this option more
    enable = false;
  };
}
