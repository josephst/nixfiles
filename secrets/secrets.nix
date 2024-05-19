let
  # users (1 key per user per device)
  # stored in ~/.ssh
  joseph = {
    joseph-nixos-proxmox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBTyMi+E14e8/droY9+Xg7ORNMMdgH1i6LsfDyKZSy4 joseph@nixos-proxmox";
    joseph-macbook-air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbookair";
    joseph-nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpnzK+uR7Bv5OVg04zk3/5TkhjtJYQGQGQOxIr6leeC joseph@nixos-orbstack";
  };

  # tmp key for new installs
  installerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmFTAIIjtDvsDUBUDFTJaCMNpdbO2/0P+g2vfJlDUtt agenix-new-install";

  # host keys (need these for BTRFS, where a user key in /home won't be mounted when secrets are trying to be decrypted)
  # stored in /etc/ssh/
  nixos-proxmox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL4F2rodZ/DMzp2bblvV3LNTHtV89XOYATeHKIwzES0D root@nixos";
  allKeys = [
    installerKey
    nixos-proxmox
  ] ++ builtins.attrValues joseph;
in
{
  "dnsApiToken.age".publicKeys = allKeys;
  "netdata_nixos_claim.age".publicKeys = allKeys;
  "rclone.conf.age".publicKeys = allKeys;
  "rcloneRemote.age".publicKeys = allKeys;
  "restic/b2WithRclone.age".publicKeys = allKeys;
  "restic/b2.env.age".publicKeys = allKeys;
  "restic/localstorage.env.age".publicKeys = allKeys;
  "restic/localstorage.pass.age".publicKeys = allKeys;
  "restic/nas.env.age".publicKeys = allKeys;
  "restic/nas.pass.age".publicKeys = allKeys;
  "rsyncd-secrets.age".publicKeys = allKeys;
  "smb.age".publicKeys = allKeys; # login for smb shares on NAS
  "smbpasswd.age".publicKeys = allKeys; # smb password database
  "users/joseph.age".publicKeys = allKeys;
  "ghToken.age".publicKeys = builtins.attrValues joseph;
  "gh_hosts.yml.age".publicKeys = builtins.attrValues joseph;
}
# `nix run github:ryantm/agenix -- --help` to run
# to rekey: get ssh private key from 1password (export -> no password)
# then run `agenix --rekey -i ~/Downloads/id_ed25519` (or whereever key was downloaded to)
