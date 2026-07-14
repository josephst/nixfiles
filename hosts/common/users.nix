{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) hostSpec;
  inherit (pkgs.stdenv) isLinux;
in
{
  age.secrets.password = lib.mkIf (hostSpec.passwordFile != null) {
    file = hostSpec.passwordFile;
  };

  users = {
    users.${hostSpec.username} = {
      inherit (hostSpec)
        home
        ;
    }
    // lib.optionalAttrs isLinux {
      group = "users";
      isNormalUser = true;
      createHome = true;
      linger = true;
      inherit (hostSpec)
        shell
        uid
        ;
      hashedPasswordFile = lib.mkIf (hostSpec.passwordFile != null) config.age.secrets.password.path;
      extraGroups = [ "wheel" ];
      packages = [ pkgs.home-manager ];
    };
  };
}
