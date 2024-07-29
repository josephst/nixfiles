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
        shell = if isDarwin then pkgs.zsh else pkgs.fish;
      }
      // lib.optionalAttrs isLinux {
        hashedPasswordFile = config.age.secrets.joseph.path;
        # hashedPassword = "REPLACE_ME"; # solves chicken/egg dilema - password file needs to already exist for Agenix to read it
        # but doesn't exist until install is done. Uncomment for install, then replace comment.
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "wheel"
          "media"
        ]; # Enable ‘sudo’ for the user.
        linger = true; # linger w/ systemd (starts user units at bootup, rather than login)
      };
  };

  nix.settings.trusted-users = [ "joseph" ];

  home-manager.users.joseph = import ../home/joseph;
  home-manager.backupFileExtension = ".backup-pre-hm";
  home-manager.extraSpecialArgs = {
    inherit (inputs) agenix;
  };
}
