{ inputs, config, lib, pkgs, ... }:
let
  cfg = config.myConfig;
  substituters = [
    {
      url = "https://nix-community.cachix.org";
      key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    }
    {
      url = "https://cache.garnix.io";
      key =  "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    }
    {
      url = "https://numtide.cachix.org";
      key = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    }
  ];
in
{
  options.myConfig = with lib; {
    nix.substituters = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional binary caches to use";
    };
    platform = mkOption {
      type = types.str;
      description = "The platform (architecture-system) this configuration is for";
    };
    tailnet = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Tailscale network identifier";
    };
    ghToken = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to GitHub token secret for Agenix";
    };
    keys = lib.mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = "SSH keys for this system and its users";
    };
    stateVersion = mkOption {
      type = types.oneOf [ types.int types.str ];
      description = "stateVersion (int for nix-darwin, string for nixOS)";
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
      settings = {
        warn-dirty = false;
        substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
        trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
        experimental-features = [ "nix-command" "flakes" ];
        log-lines = lib.mkDefault 25;
        builders-use-substitutes = true;
        cores = 0;
      };
    };

    programs = {
      # programs available on both nixOS and nix-darwin
      fish = {
        enable = true;
        useBabelfish = true;
        shellAliases = {
          nano = "micro";
        };
      };
      nix-index-database.comma.enable = true; # from https://github.com/nix-community/nix-index-database
    };

    age = {
      secrets.ghToken = lib.mkIf (cfg.ghToken != null) {
        file = cfg.ghToken;
        mode = "0440";
      };
    };

    environment = {
      variables = {
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
      };
      systemPackages = [
        pkgs.deploy-rs
        pkgs.agenix
        pkgs.git
        pkgs.micro
        pkgs.nix-output-monitor
        pkgs.nvd
      ];
    };
  };
}
