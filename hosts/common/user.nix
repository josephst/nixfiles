{
  inputs,
  outputs,
  config,
  lib,
  ...
}:

let
  hostSpec = config.hostSpec;
  username = hostSpec.username;
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
  };
}
