{
  hosts = {
    # special key to be used prior to re-keying the system, placed at /etc/agenixKey
    installerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmFTAIIjtDvsDUBUDFTJaCMNpdbO2/0P+g2vfJlDUtt agenix-new-install";

    Josephs-MacBook-Air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4LUu5VYk6fVSjJoBXjvQc3VNTor4krhhezFg60/+iG root@Josephs-MacBook-Air";
    terminus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL4F2rodZ/DMzp2bblvV3LNTHtV89XOYATeHKIwzES0D root@nixos";
    anacreon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoGRrCCPe6oXw4FCfWgimXoUY2kxisYu3rUyl8F+ZrD root@anacreon"; # VM on UTM (macbook air)
    nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBL3m6s7bwvuODKtaS8C+DKKGxNkMyKaYoBQobT7bq8g root@nixos-orbstack";
  };

  users = {
    joseph = {
      # agenix: special key which is used to decrypt user's $HOME across all machines (including before a machine-specific key is set up)
      agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrRmKWGnpr9wv6Rw5SyHXKPJwMqDS7pR3NHjlepBSxH agenix-home";

      Josephs-MacBook-Air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air";
      nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpnzK+uR7Bv5OVg04zk3/5TkhjtJYQGQGQOxIr6leeC joseph@nixos-orbstack";
      terminus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBTyMi+E14e8/droY9+Xg7ORNMMdgH1i6LsfDyKZSy4 joseph@terminus"; # terminus = VM on proxmox
    };
  };
}
