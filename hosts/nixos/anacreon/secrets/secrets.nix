let
  keys = import ../../../../keys;

  hostKeys = if keys.hostKeys ? anacreon then [ keys.hostKeys.anacreon ] else [ ];
  publicKeys = builtins.attrValues keys.ageRecipients.joseph ++ hostKeys;
in
{
  "cloudflare-dns.age".publicKeys = publicKeys;
  "tailscale-authkey.age".publicKeys = publicKeys;
  "paperless-admin.age".publicKeys = publicKeys;
  "restic/paperless-repository.age".publicKeys = publicKeys;
  "restic/paperless-password.age".publicKeys = publicKeys;
  "restic/paperless.env.age".publicKeys = publicKeys;
}
