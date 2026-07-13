# Agenix - Secrets (for $HOME)

This directory contains user-specific secrets.
Decrypted with the Agenix home-manager module.

Encrypted with user-specific keys, as these are specific to the user's $HOME folder
and don't need to be accessible to entire system.

## Contents and consumers

- `gh_hosts.yml.age`: GitHub CLI hosts configuration for profiles that enable
  the corresponding Agenix secret.
- `1pass.env.age`: `OP_SERVICE_ACCOUNT_TOKEN=...` environment-file form.
- `1pass.age`: the same token value without an assignment, for Fish.

The 1Password service-account variants are decrypted only on server roles.
All files use `keys.ageRecipients.joseph`; those recipients grant decryption,
not SSH login. Rotate a value with `agenix -e`, then run `agenix -r` whenever
the recipient set changes and rebuild every consuming host.
