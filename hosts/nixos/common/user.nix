# NixOS-specific user options
{
  config,
  lib,
  ...
}:
let
  inherit (config) hostSpec;
  inherit (config.myConfig) keys;
  inherit (hostSpec) username;
in
{
  age.secrets.password = lib.mkIf (hostSpec.passwordFile != null) {
    file = hostSpec.passwordFile;
  };

  users = {
    users.${username} = {
      inherit (hostSpec) home;
    };
    users.root = {
      hashedPassword = lib.mkDefault null;
      openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
    };
  };
}
