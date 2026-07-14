let
  keys = import ../../../../keys;
in
{
  "cloudflare-dns.age".publicKeys = keys.recipientGroups.anacreon;
  "tailscale-authkey.age".publicKeys = keys.recipientGroups.anacreon;
  "paperless-admin.age".publicKeys = keys.recipientGroups.anacreon;
  "restic/paperless-repository.age".publicKeys = keys.recipientGroups.anacreon;
  "restic/paperless-password.age".publicKeys = keys.recipientGroups.anacreon;
  "restic/paperless.env.age".publicKeys = keys.recipientGroups.anacreon;
}
