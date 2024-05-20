let
  joseph = {
    joseph-nixos-proxmox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBTyMi+E14e8/droY9+Xg7ORNMMdgH1i6LsfDyKZSy4 joseph@nixos-proxmox";
    joseph-macbook-air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbookair";
    joseph-nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpnzK+uR7Bv5OVg04zk3/5TkhjtJYQGQGQOxIr6leeC joseph@nixos-orbstack";
  };
in {
  "gh_hosts.yml.age".publicKeys = builtins.attrValues joseph;
}
