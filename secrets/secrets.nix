let
  joseph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmAAEPEulCuQrrU/T2h0pLDdr6BIMycaCa7IEJ24G7X root@nixos";
  newSystem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINRhc76Xo/X+GXNkWKxdr6kdb/+btJ5tu32i7Tp36tri root@nixos";
  allKeys = [joseph system newSystem];
in {
  "smb.age".publicKeys = allKeys;
  "hashedUserPassword.age".publicKeys = allKeys;
  "dnsApiToken.age".publicKeys = allKeys;
  "rcloneConf.age".publicKeys = allKeys;
  "resticLan.env.age".publicKeys = allKeys;
  "resticb2.env.age".publicKeys = allKeys;
  "restic.pass.age".publicKeys = allKeys;
  "netdata_nixos_claim.age".publicKeys = allKeys;
}
# `nix run github:ryantm/agenix -- --help` to run
# to rekey: get ssh private key from 1password (export -> no password)
# then run `agenix --rekey -i ~/Downloads/id_ed25519` (or whereever key was downloaded to)

