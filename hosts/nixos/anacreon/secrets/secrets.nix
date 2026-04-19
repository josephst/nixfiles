let
  keys = import ../../../../keys;

  hostKeys = if keys.hosts ? anacreon then [ keys.hosts.anacreon ] else [ ];
  publicKeys = builtins.attrValues keys.users.joseph ++ hostKeys;
in
{
  "cloudflare-dns.age".publicKeys = publicKeys;
  "tailscale-authkey.age".publicKeys = publicKeys;
  "paperless-admin.age".publicKeys = publicKeys;
}
