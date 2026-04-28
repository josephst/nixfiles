{
  inputs,
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
    ./scripts
  ];

  config = {
    home = {
      stateVersion = "26.05";
    };

    # new Agenix configuration which is *user-specific* (DISTINCT from the system Agenix config)
    age = {
      identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ] ++ options.age.identityPaths.default;
    };

    programs = {
      # Home Manager 26.05 defaults `programs.man.package = null` on Darwin, so
      # fish's cache-generation default only creates a warning there.
      man.generateCaches = lib.mkIf (isDarwin && config.programs.man.package == null) false;

      # from inputs.nix-index-database
      nix-index.enable = true;
    };
    xdg = {
      enable = true;
      localBinInPath = true;
      userDirs = {
        enable = isLinux;
        createDirectories = true;
        extraConfig = {
          SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };
  };
}
