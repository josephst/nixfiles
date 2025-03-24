{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.myConfig;
  substituters = { };
in
{
  imports = [
    inputs.disko.darwinModules.disko
    inputs.home-manager.darwinModules.home-manager
    inputs.agenix.darwinModules.default
    inputs.nix-index-database.darwinModules.nix-index
  ];

  options.myConfig = with lib; {
    nix.substituters = mkOption {
      type = types.listOf types.str;
      # TODO: populate with well-known substituters
      default = [ ];
    };
    platform = mkOption {
      type = types.str;
      default = "aarch64-darwin";
    };
    stateVersion = mkOption {
      type = types.str;
      default = "4";
    };
    tailnet = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = {
    nixpkgs = {
      hostPlatform = cfg.platform;
    };
  };
}
