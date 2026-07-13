# Keys

Based on [ambroisie nixconfig](https://github.com/ambroisie/nix-config/blob/9e89b4dd36b3b98430a8460e7c53f1e6185f116d/keys/default.nix)

Keys are divided by purpose:

- `loginKeys`: user SSH login keys. These should be unique per user and machine.
- `ageRecipients`: keys allowed to decrypt Agenix secrets. This includes the
  login keys plus dedicated decryption and rekeying keys, but only `loginKeys`
  are installed in `authorized_keys`.
- `hostKeys`: SSH host keys (found at `/etc/ssh/ssh_host_ed25519_key.pub`).
- `signingKeys`: Git commit-signing public keys.

If a host SSH key does not exist, it can be created with `sudo ssh-keygen -A`.

As new systems are created, add them to `hostKeys` and `loginKeys`, include the
login key in `ageRecipients`, and rekey secrets if necessary.

## Using

When secrets are needed, create a `secrets/` folder.
Within secrets folder, create two files:
1. `secrets.nix` - the file that Agenix uses to determine which keys can encrypt/decrypt a given file
2. `default.nix` - loads the secrets (`age.secrets.<secret-name>.file = ./path/to/file`)

Then, secrets can be be consumed via `foo.passwordFile = config.age.secrets.my-secret.path` in various modules.
