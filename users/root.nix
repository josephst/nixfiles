{
  lib,
  pkgs,
  config,
  ...
}:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBTyMi+E14e8/droY9+Xg7ORNMMdgH1i6LsfDyKZSy4 joseph@nixos-proxmox"
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
