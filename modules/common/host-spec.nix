# Specifications For Differentiating Hosts
{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.hostSpec = {
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };

    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for the host's user";
    };

    userFullName = lib.mkOption {
      type = lib.types.str;
      description = "The full name of the user";
    };

    passwordFile = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.path;
      description = "Hashed password file for agenix";
    };

    home = lib.mkOption {
      type = lib.types.str;
      description = "The home directory of the user";
      default =
        let
          user = config.hostSpec.username;
        in
        if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
    };

    platform = lib.mkOption {
      type = lib.types.str;
      description = "The platform of the host";
      default = "x86_64-linux";
    };

    isMinimal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a minimal configuration host";
    };

    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a server host";
    };

    desktop = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "Gnome"
        ]
      );
      default = if (config.hostSpec.isServer || pkgs.stdenv.isDarwin) then null else "Gnome";
      description = "Desktop environment (Gnome or null)";
    };

    shell = lib.mkOption {
      type = lib.types.enum [
        pkgs.fish
        pkgs.bash
      ];
      default = pkgs.fish;
      description = "Default shell (pkgs.fish or pkgs.bash)";
    };

    tailnet = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Tailscale network identifier";
    };

    # stateVersion = lib.mkOption {
    #   type = lib.types.oneOf [
    #     lib.types.int
    #     lib.types.str
    #   ];
    #   description = "stateVersion (int for nix-darwin, string for nixOS)";
    # };
  };

  config = {
    networking.hostName = lib.mkDefault config.hostSpec.hostName;
  };
}
