{
  inputs,
  outputs,
  config,
  lib,
  ...
}:

let
  inherit (config) hostSpec;
  inherit (hostSpec) username;
  home = ../../home/${username};
in
{
  home-manager = {
    useGlobalPkgs = lib.mkDefault true;
    useUserPackages = lib.mkDefault true;
    extraSpecialArgs = {
      inherit inputs;
    };
    backupFileExtension = ".backup-pre-hm";
    sharedModules = builtins.attrValues outputs.homeManagerModules;

    users.${username} = import home;
    users.root.home.stateVersion = "24.11"; # avoid error
  };
}
