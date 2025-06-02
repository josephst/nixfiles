{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myConfig;
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
  ];

  # Platform-specific trusted users
  trustedUsers = if pkgs.stdenv.isDarwin then [ "@admin" ] else [ "@wheel" ];
in
{
  options.myConfig.nix = with lib; {
    substituters = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional binary caches to use";
    };

    trustedUsers = mkOption {
      type = types.listOf types.str;
      default = trustedUsers;
      description = "Users trusted to use nix";
    };
  };

  config = {
    nix = {
      package = pkgs.nix;
      extraOptions = lib.optionalString (config.age.secrets ? "ghToken") ''
        !include ${config.age.secrets.ghToken.path}
      '';
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings =
        {
          warn-dirty = false;
          substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
          trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
          trusted-users = cfg.nix.trustedUsers;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          log-lines = lib.mkDefault 25;
          builders-use-substitutes = true;
          cores = 0;
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          sandbox = "relaxed";
        };

      gc = {
        automatic = lib.mkIf (config.nix.enable) true;
      };
    };
  };
}
