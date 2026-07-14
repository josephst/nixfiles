# Specifications For Differentiating Hosts
let
  supportedPlatforms = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
in
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

    uid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "The UID for the host's primary user";
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
      type = lib.types.enum supportedPlatforms;
      description = "The platform of the host";
      default = "x86_64-linux";
    };

    role = lib.mkOption {
      type = lib.types.enum [
        "containerGuest"
        "installer"
        "server"
        "workstation"
      ];
      description = "The host's primary operational role";
    };

    cliProfile = lib.mkOption {
      type = lib.types.enum [
        "full"
        "minimal"
      ];
      default = "full";
      description = "Size of the interactive command-line tool profile";
    };

    shell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fish;
      description = "Default login shell package";
    };

    tailnet = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Tailscale MagicDNS suffix used to construct host names";
    };
  };

  config = {
    networking.hostName = lib.mkDefault config.hostSpec.hostName;
  };
}
