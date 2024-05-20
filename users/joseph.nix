{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  keys = import ../keys;
in
{
  age.secrets.joseph.file = ./secrets/users/joseph.age;

  users.users = {
    joseph =
      {
        description = "Joseph Stahl";
        home = if isDarwin then "/Users/joseph" else "/home/joseph";
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
      }
      // lib.optionalAttrs isLinux {
        hashedPasswordFile = config.age.secrets.joseph.path;
        # hashedPassword = "REPLACE_ME"; # solves chicken/egg dilema - password file needs to already exist for Agenix to read it
        # but doesn't exist until install is done. Uncomment for install, then replace comment.
        isNormalUser = true;
        createHome = true;
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "media"
        ]; # Enable ‘sudo’ for the user.
      };
  };

  nix.settings.trusted-users = [ "joseph" ];

  home-manager.users.joseph = import ../home/joseph;
  home-manager.extraSpecialArgs = {
    agenix = inputs.agenix;
  };
}
