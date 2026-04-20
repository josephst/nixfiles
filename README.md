# Nixfiles

[Read the companion blog post](https://josephstahl.com/nix-for-macos-and-a-homelab-server/)

Personal Nix configuration for macOS and NixOS, built around a single flake with shared host metadata, shared modules, and Home Manager integration. This repository manages one nix-darwin workstation, several NixOS systems, and the supporting packages, overlays, keys, and encrypted secrets they use.

## Repository Layout

- `flake.nix`: entrypoint for all `darwinConfigurations`, `nixosConfigurations`, overlays, packages, formatter, and dev shells
- `lib/`: helper functions used to assemble Darwin and NixOS systems
- `modules/common/`: shared options, including `hostSpec` and `myConfig`
- `modules/darwin/`: Darwin module exports
- `modules/nixos/`: reusable NixOS modules such as `backrest`, `healthchecks`, `rcloneSync`, and `recyclarr`
- `modules/home-manager/`: Home Manager module exports
- `hosts/common/`: cross-platform host configuration shared by nix-darwin and NixOS
- `hosts/darwin/`: Darwin host definitions
- `hosts/nixos/`: NixOS host definitions, hardware config, disk layout, networking, services, and host-local secrets
- `home/`: Home Manager configuration for `joseph` plus shared scripts
- `pkgs/`, `pkgsLinux/`, `overlays/`: custom packages and overlay wiring
- `keys/`: SSH public keys used for access and agenix recipients
- `secrets/`: shared agenix-encrypted secrets

## Hosts

### Darwin

- `Josephs-MacBook-Air` (`aarch64-darwin`): primary macOS machine, configured with nix-darwin and Home Manager

### NixOS

- `terminus` (`x86_64-linux`): primary homelab server with Home Assistant, media services, backups, Caddy, Copyparty, Ollama, and related services
- `anacreon` (`x86_64-linux`): minimal server with Tailscale-first access and self-hosted services including Homepage, Backrest, Copyparty, and Paperless
- `orbstack` (`aarch64-linux`): local Linux environment
- `iso-gnome` (`x86_64-linux`): installer/live ISO configuration

## Common Workflows

### Switch the current machine

```bash
just switch
```

This stages tracked changes with `git add --all` and then uses `nh` to switch the active configuration:

- macOS: `nh darwin switch .`
- Linux: `nh os switch .`

### Update inputs

```bash
just update
```

On macOS this also runs `brew update` before `nix flake update --commit-lock-file`.

### Deploy the remote server

```bash
just deploy
```

The current deploy recipe targets `anacreon` with `nixos-rebuild` over SSH:

```bash
nix run nixpkgs#nixos-rebuild -- \
  --target-host joseph@anacreon \
  --sudo switch \
  --flake .#anacreon \
  --build-host anacreon \
  --no-reexec \
  --use-substitutes
```

If remote activation needs a password prompt, rerun with `--ask-sudo-password` so the remote `sudo` step can complete interactively.

### Check and format

```bash
nix fmt
nix flake check
```

For targeted builds:

```bash
nix build .#darwinConfigurations.Josephs-MacBook-Air.system
nix build .#nixosConfigurations.terminus.config.system.build.toplevel
nix build .#nixosConfigurations.anacreon.config.system.build.toplevel
```

## NixOS Installation Notes

New NixOS systems are intended to be installed with `nixos-anywhere`, with disk layout defined in the host's `disko.nix`.

Example:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#<host> \
  --target-host nixos@<ip-or-hostname> \
  --build-on remote
```

This repo expects the Home Manager agenix identity at `~/.ssh/agenix` on first boot. `nixos-anywhere --extra-files` copies a local directory tree into the installed system root, so provide the key under `home/joseph/.ssh/agenix` in a temporary directory and set the final ownership numerically:

```bash
temp="$(mktemp -d)"
trap 'rm -rf "$temp"' EXIT

install -d -m 700 "$temp/home/joseph/.ssh"
install -m 600 ~/.ssh/agenix "$temp/home/joseph/.ssh/agenix"

nix run github:nix-community/nixos-anywhere -- \
  --flake .#<host> \
  --target-host nixos@<ip-or-hostname> \
  --build-on remote \
  --extra-files "$temp" \
  --chown /home/joseph/.ssh 1000:100
```

The numeric `1000:100` matches the hard-coded `joseph` UID and primary `users` group GID in this flake, so the ownership is correct even before the user account exists on the target system.

When the target host also needs system agenix secrets during bootstrap:

- add the host SSH key to `keys/`
- update the relevant `secrets.nix` recipients
- **rekey with `agenix -r`**
- use `--copy-host-keys` when the install flow depends on preserving an existing `/etc/ssh/ssh_host_*` identity for secret decryption
- use `--extra-files` to seed `/etc/ssh/ssh_host_*` on brand-new machines when there is no existing host key to preserve

## Secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix).

- shared secrets live under `secrets/`
- host-specific secrets live under `hosts/nixos/<host>/secrets/`
- user secrets live under `home/joseph/secrets/`

Never commit plaintext secrets. Edit encrypted values with `agenix -e` and rekey with `agenix -r` after adding or rotating recipients.

## Notes

- `nix` evaluation in this repo only sees Git-tracked files, so `git add --all` new files before relying on `nix eval`, `nix build`, or `nix flake check`
- `hosts/common/` is an important shared layer for users, SSH infrastructure, Home Manager wiring, and global Nix settings
- `hostSpec` is the shared source of per-host identity and platform metadata across Darwin and NixOS systems
