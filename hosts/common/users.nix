{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) hostSpec;
  inherit (config.myConfig) keys;
  inherit (pkgs.stdenv) isLinux;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  age.secrets.password = lib.mkIf (hostSpec.passwordFile != null) {
    file = hostSpec.passwordFile;
  };

  users = {
    users.${hostSpec.username} = {
      inherit (hostSpec) home;
    }
    // lib.optionalAttrs isLinux {
      isNormalUser = true;
      createHome = true;
      linger = true;
      inherit (hostSpec) shell;
      hashedPasswordFile = lib.mkIf (hostSpec.passwordFile != null) config.age.secrets.password.path;
      extraGroups = ifTheyExist [
        "wheel"
        "networkmanager"
        "media"
        "incus-admin"
        "render"
      ];
      packages = [ pkgs.home-manager ];
    };

    users.root = lib.mkIf isLinux {
      hashedPassword = null; # only permit ssh keys for root
      openssh.authorizedKeys.keys = lib.optionals (
        keys != null && lib.hasAttrByPath [ "users" "joseph" ] keys
      ) (builtins.attrValues keys.users.joseph);
    };
  };
}
