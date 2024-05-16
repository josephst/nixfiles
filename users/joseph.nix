{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph@1password"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air"
  ];
in
{
  users.users = {
    joseph =
      {
        description = "Joseph Stahl";
        home = if isDarwin then "/Users/joseph" else "/home/joseph";
        openssh.authorizedKeys.keys = keys;
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
}
