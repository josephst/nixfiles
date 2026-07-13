let
  keys = import ../../../../keys;

  # Accessing the attribute directly makes a missing host recipient an
  # evaluation error rather than silently producing user-only ciphertext.
  publicKeys = builtins.attrValues keys.ageRecipients.joseph ++ [ keys.hostKeys.anacreon ];
in
{
  "cloudflare-dns.age".publicKeys = publicKeys;
  "tailscale-authkey.age".publicKeys = publicKeys;
  "paperless-admin.age".publicKeys = publicKeys;
  "restic/paperless-repository.age".publicKeys = publicKeys;
  "restic/paperless-password.age".publicKeys = publicKeys;
  "restic/paperless.env.age".publicKeys = publicKeys;
}
