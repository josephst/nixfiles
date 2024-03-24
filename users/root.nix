{
  lib,
  pkgs,
  config,
  ...
}:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph@1password"
  ];
in
{
  users.users = {
    root = {
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keys = keys;
    };
  };
}
