let
  keys = import ../../../../keys;

  hostKeys = if keys.hosts ? anacreon then [ keys.hosts.anacreon ] else [ ];
  publicKeys = builtins.attrValues keys.users.joseph ++ hostKeys;
in
{
  "cloudflare-dns.age".publicKeys = publicKeys;
  "tailscale-authkey.age".publicKeys = publicKeys;
  "paperless-admin.age".publicKeys = publicKeys;
  "restic/paperless-repository.age".publicKeys = publicKeys;
  "restic/paperless-password.age".publicKeys = publicKeys;
  "restic/paperless.env.age".publicKeys = publicKeys;
}
