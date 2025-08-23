{
  config,
  lib,
  pkgs,
  ...
}:
let
  substituters = [
    {
      url = "https://nix-community.cachix.org";
      key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    }
    {
      url = "https://cache.garnix.io";
      key = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    }
    {
      url = "https://numtide.cachix.org";
      key = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    }
    {
      url = "https://install.determinate.systems";
      key = "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=";
    }
  ];

  # Platform-specific trusted users
  trustedUsers = if pkgs.stdenv.isDarwin then [ "@admin" ] else [ "@wheel" ];
in
{
  config = {
    nix = {
      enable = lib.mkDefault (!pkgs.stdenv.isDarwin); # on darwin, nix is managed by Determinate Nix

      # remaining options only applied on non-Darwin systems
      package = lib.mkDefault pkgs.nix;
      # registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      # nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = {
        warn-dirty = false;
        substituters = map (x: x.url) substituters;
        trusted-public-keys = map (x: x.key) substituters;
        trusted-users = trustedUsers;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        log-lines = lib.mkDefault 25;
        builders-use-substitutes = true;
        cores = 0;
      };

      gc = {
        automatic = lib.mkIf config.nix.enable true;
      };
    };
  };
}
