{
  inputs,
  pkgs,
  lib,
  ...
}: let
  user = "joseph";
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = import ../../home/${user};
  };
  nix = {
    package = pkgs.nix;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      cores = lib.mkDefault 4;
      max-jobs = lib.mkDefault 4;
      trusted-users = ["root" user];
      allowed-users = ["root" user];
    };
    extraOptions = ''
      extra-substituters = https://nix-community.cachix.org
      extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
      keep-outputs = true
      keep-derivations = true
      extra-nix-path = nixpkgs=flake:nixpkgs
    '';
  };

  environment = {
    variables = {
      LANG = "en_US.UTF-8";
      SHELL = "${pkgs.zsh}/bin/zsh";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages =
      lib.attrValues {
        inherit
          (pkgs)
          agenix
          binutils
          coreutils
          curl
          deploy-rs
          fish
          mkpasswd
          rclone
          wget
          zsh
          ;
      }
      ++ [
        (pkgs.git.override {osxkeychainSupport = false;})
      ];
  };

  fonts = {
    fontDir.enable = true;
    fonts =
      lib.attrValues {
        inherit
          (pkgs)
          source-code-pro
          font-awesome
          ;
      }
      ++ [
        (pkgs.nerdfonts.override {
          fonts = [
            "FiraCode"
            "Hack"
          ];
        })
      ];
  };

  # programs.(fish|zsh).enable must be defined here *and* in home-manager section
  # otherwise, nix won't be added to path in fish shell
  programs.fish.enable = true;
  programs.zsh.enable = true;
}
