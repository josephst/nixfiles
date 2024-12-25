let
  keys = import ../../../../keys;

  # include all `joseph` keys to allow me to rekey secrets with my user key
  allKeys = builtins.attrValues keys.users.joseph ++ [
    keys.hosts.terminus
    keys.hosts.installerKey
  ];
in
{
  "dnsApiToken.age".publicKeys = allKeys;
  "netdata_nixos_claim.age".publicKeys = allKeys;
  "paperless-admin.age".publicKeys = allKeys;
  "rclone.conf.age".publicKeys = allKeys;
  "restic/b2.env.age".publicKeys = allKeys;
  "restic/b2bucketname.age".publicKeys = allKeys; # bucket name for restic (B2, using S3-compatible API)
  "restic/localstorage.pass.age".publicKeys = allKeys;
  "restic/restic-server-maintenance.env.age".publicKeys = allKeys;
  "restic/rclone-sync.env.age".publicKeys = allKeys;
  # "restic/systembackup.env.age".publicKeys = allKeys;
  "smbpasswd.age".publicKeys = allKeys; # smb password database
  "zwave-js-keys.json.age".publicKeys = allKeys;
}
# `nix run github:ryantm/agenix -- --help` to run
# to rekey: get ssh private key from 1password (export -> no password)
# then run `agenix --rekey -i ~/Downloads/id_ed25519` (or whereever key was downloaded to)
