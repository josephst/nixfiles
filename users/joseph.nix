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
        isNormalUser = true;
        createHome = true;
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "media"
        ]; # Enable ‘sudo’ for the user.
      };
  };

  nix.settings.extra-trusted-users = [ "joseph" ];

  home-manager.users.joseph = import ../home/joseph;
}
