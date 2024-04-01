{
  lib,
  pkgs,
  config,
  ...
}:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph@1password"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air"
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
