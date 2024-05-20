# Keys

Based on [ambroisie nixconfig](https://github.com/ambroisie/nix-config/blob/9e89b4dd36b3b98430a8460e7c53f1e6185f116d/keys/default.nix)

Divided into:
- `users`: User SSH keys (such as those found at `~./ssh/id_ed25519.pub`).
These should be unique, so that the same user on different systems has a unique key. 
- `hosts`: Host SSH keys (found at `/etc/ssh/etc/ssh/ssh_host_ed25519_key.pub`)

If a host SSH key does not exist, it can be created with `sudo ssh-keygen -A`.

As new systems are created, add them to `hosts/` and rekey secrets if necessary. 
