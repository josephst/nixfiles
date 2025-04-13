{ inputs, config, lib, pkgs, options, ... }:

let
  inherit (pkgs.stdenv) isLinux;

  cfg = config.myHomeConfig;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.hmModules.nix-index

    ./scripts
    ./llm.nix
  ];

  # TODO: find a way to limit this to only apply to "joseph" user, right now it's causing conflicts with root
  options.myHomeConfig = {
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "24.11";
      description = ''
        home-manager stateVersion, should be kept the same or *very carefully* updated
        after reading release notes.
      '';
    };

    keys = lib.mkOption {
      # TODO: eventually move this to a submodule that can check the attributes
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "SSH keys for users on this system";
    };
  };

  config = {
    home = {
      inherit (cfg) stateVersion;
    };

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    };

    # new Agenix configuration which is *user-specific* (DISTINCT from the system Agenix config)
    age = {
      identityPaths = [ "~/.ssh/agenix" ] ++ options.age.identityPaths.default;
    };
    xdg = {
      enable = true;
      userDirs = {
        enable = isLinux;
        createDirectories = true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };
  };
}
