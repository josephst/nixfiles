# NixOS-specific user options
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostSpec = config.hostSpec;
  keys = config.myConfig.keys;
  username = hostSpec.username;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  age.secrets.password = lib.mkIf (hostSpec.passwordFile != null) {
    file = hostSpec.passwordFile;
  };

  users = {
    users.${username} = {
      home = hostSpec.home;
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
    users.root = {
      hashedPassword = lib.mkDefault null;
      openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
    };
  };
}
