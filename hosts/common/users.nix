{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) hostSpec;
  inherit (pkgs.stdenv) isLinux;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users = {
    users.${hostSpec.username} =
      {
        inherit (hostSpec) home;
      }
      // lib.optionalAttrs isLinux {
        isNormalUser = true;
        createHome = true;
        inherit (hostSpec) shell;
        hashedPasswordFile = lib.mkIf (hostSpec.passwordFile != null) config.age.secrets.password.path;
        extraGroups = ifTheyExist [
          "wheel"
          "networkmanager"
        ];
        packages = [ pkgs.home-manager ];
      };
  };
}
