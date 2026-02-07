{
  inputs,
  config,
  pkgs,
  options,
  ...
}:

let
  inherit (pkgs.stdenv) isLinux;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
    ./scripts
  ];

  config = {
    home = {
      stateVersion = "25.11";
    };

    # new Agenix configuration which is *user-specific* (DISTINCT from the system Agenix config)
    age = {
      identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ] ++ options.age.identityPaths.default;
    };
    xdg = {
      enable = true;
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
