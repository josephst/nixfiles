let
  keys = import ../../../../keys;

  # include all `joseph` keys to allow me to rekey secrets with my user key
  allKeys = builtins.attrValues keys.users.joseph ++ [ keys.hosts.nixos-proxmox keys.hosts.installerKey ];
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
}
# `nix run github:ryantm/agenix -- --help` to run
# to rekey: get ssh private key from 1password (export -> no password)
# then run `agenix --rekey -i ~/Downloads/id_ed25519` (or whereever key was downloaded to)
