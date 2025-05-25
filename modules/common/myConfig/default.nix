{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./keys.nix
    ./nixpkgs.nix
    ./nix-settings.nix
    ./ssh-infrastructure.nix
  ];
  options.myConfig = with lib; {
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
      description = "Path to GitHub token secret (avoid rate-limiting by GitHub)";
    };
    stateVersion = mkOption {
      type = types.oneOf [
        types.int
        types.str
      ];
      description = "stateVersion (int for nix-darwin, string for nixOS)";
    };
  };

  config = {
    # Nix configuration is now handled by ./nix-settings.nix

    programs = {
      # programs available on both nixOS and nix-darwin
      fish = {
        enable = true;
        useBabelfish = true;
        shellAliases = {
          nano = "micro";
          fnix = "nix-shell --run fish"; # use as `fnix -p go` to have a fish shell with go in it
        };
      };
      nix-index-database.comma.enable = true; # from https://github.com/nix-community/nix-index-database

      # SSH configuration is now handled by ./ssh-infrastructure.nix
    };

    age = {
      secrets.ghToken = lib.mkIf (config.myConfig.ghToken != null) {
        file = config.myConfig.ghToken;
        mode = "0440";
      };
    };

    environment = {
      variables = {
        EDITOR = "hx";
        SYSTEMD_EDITOR = "hx";
        VISUAL = "hx";
      };
      systemPackages = [
        pkgs.deploy-rs
        pkgs.agenix
        pkgs.helix
        pkgs.git
        pkgs.nix-output-monitor
        pkgs.nvd
      ];
    };
  };
}
