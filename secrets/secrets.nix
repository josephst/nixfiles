let
  # users
  joseph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop";

  # systems
  nixos-proxmox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdEOEVwz2xyTtGE3EHIy7gTepGCbyqnU5SDd6/2/EkL root@nixos";
  allKeys = [joseph nixos-proxmox];
in {
  "dnsApiToken.age".publicKeys = allKeys;
  "netdata_nixos_claim.age".publicKeys = allKeys;
  "rclone/rclone.conf.age".publicKeys = allKeys;
  "restic/b2.env.age".publicKeys = allKeys;
  "restic/exthdd.env.age".publicKeys = allKeys;
  "restic/exthdd.pass.age".publicKeys = allKeys;
  "restic/nas.env.age".publicKeys = allKeys;
  "restic/nas.pass.age".publicKeys = allKeys;
  "rsyncd-secrets.age".publicKeys = allKeys;
  "smb.age".publicKeys = allKeys;
  "users/joseph.age".publicKeys = allKeys;
  "ghToken.age".publicKeys = allKeys;
}
# `nix run github:ryantm/agenix -- --help` to run
# to rekey: get ssh private key from 1password (export -> no password)
# then run `agenix --rekey -i ~/Downloads/id_ed25519` (or whereever key was downloaded to)

