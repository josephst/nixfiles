# Keys

Based on [ambroisie nixconfig](https://github.com/ambroisie/nix-config/blob/9e89b4dd36b3b98430a8460e7c53f1e6185f116d/keys/default.nix)

Divided into:
- `users`: User SSH keys (such as those found at `~./ssh/id_ed25519.pub`).
These should be unique, so that the same user on different systems has a unique key. 
- `hosts`: Host SSH keys (found at `/etc/ssh/etc/ssh/ssh_host_ed25519_key.pub`)

If a host SSH key does not exist, it can be created with `sudo ssh-keygen -A`.

As new systems are created, add them to `hosts` and rekey secrets if necessary. 

## Using

When secrets are needed, create a `secrets/` folder.
Within secrets folder, create two files:
1. `secrets.nix` - the file that Agenix uses to determine which keys can encrypt/decrypt a given file
2. `default.nix` - loads the secrets (`age.secrets.<secret-name>.file = ./path/to/file`)

Then, secrets can be be consumed via `foo.passwordFile = config.age.secrets.my-secret.path` in various modules.
