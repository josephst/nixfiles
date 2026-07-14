# Nixfiles

[Read the companion blog post](https://josephstahl.com/nix-for-macos-and-a-homelab-server/)

Personal Nix configuration for macOS and NixOS, built around a single flake with shared host metadata, shared modules, and Home Manager integration. This repository manages one nix-darwin workstation, several NixOS systems, and the supporting packages, overlays, keys, and encrypted secrets they use.

## Repository Layout

- `flake.nix`: entrypoint for all `darwinConfigurations`, `nixosConfigurations`, overlays, packages, formatter, and dev shells
- `lib/`: helper functions used to assemble Darwin and NixOS systems
- `modules/common/`: shared options, including `hostSpec` and `myConfig`
- `modules/darwin/`: Darwin module exports
- `modules/nixos/`: reusable NixOS modules such as `backrest`, `healthchecks`, `rcloneSync`, and `recyclarr`
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

- `terminus` (`x86_64-linux`, `server`): currently dormant homelab configuration
- `anacreon` (`x86_64-linux`, `server`): minimal server with Tailscale-first access and self-hosted services including Homepage, Backrest, Copyparty, and Paperless
- `orbstack` (`aarch64-linux`, `containerGuest`): local Linux environment
- `iso-gnome` (`x86_64-linux`, `installer`): installer/live ISO configuration

## Common Workflows

### Switch the current machine

```bash
just switch
```

This uses `nh` to switch the active configuration:

- macOS: `nh darwin switch .`
- Linux: `nh os switch .`

Nix flakes ignore untracked files. Explicitly stage newly created files that the
configuration imports, but do not stage unrelated work merely to switch.

### Update inputs

```bash
just update
```

On macOS this also runs `brew update` before `nix flake update --commit-lock-file`.

### Deploy the remote server

```bash
just deploy
```

The current deploy recipe targets `anacreon` with `nh` over SSH:

```bash
nix run nixpkgs#nh -- os switch .#anacreon \
  --target-host joseph@anacreon \
  --build-host joseph@anacreon \
  --use-substitutes
```

### Check and format

```bash
nix fmt
nix flake check --all-systems --no-build
nix flake check
```

The first command evaluates every exported system without requiring builders
for every platform. The second builds the checks native to the current machine;
use a full `--all-systems` check when the configured remote builders are
available.

For targeted builds:

```bash
nix build .#darwinConfigurations.Josephs-MacBook-Air.system
nix build .#nixosConfigurations.anacreon.config.system.build.toplevel
nix build .#nixosConfigurations.orbstack.config.system.build.toplevel
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

## Backup recovery boundary

The root-run Paperless and Backrest Restic units create separate, serialized
snapshots of the Paperless export and `/var/lib/backrest`. Backrest runs as its
own unprivileged user and owns repository retention, checks, browsing, and
staged restores. It does not receive read or write access to Paperless's live
data. Restore into a directory under `/var/lib/backrest` first, then import or
copy data deliberately as root.

The step-by-step backup-chain and staged-restore procedure is documented in
[`docs/anacreon-recovery.md`](docs/anacreon-recovery.md). A Paperless import
must use a completely empty instance running the same Paperless version that
created the export.

The repository-wide architecture and technical-debt audit, including retained
workarounds and their removal conditions, is maintained in
[`CODEBASE_REVIEW.md`](CODEBASE_REVIEW.md).

## Notes

- Git-flake evaluation only sees tracked or explicitly staged paths. Add newly imported files by exact path before switching; do not stage unrelated files.
- `hosts/common/` is an important shared layer for users, SSH infrastructure, Home Manager wiring, and global Nix settings
- `hostSpec` is the shared source of identity, platform, operational role, and CLI-profile metadata. NixOS, nix-darwin, and Home Manager migration versions remain beside each concrete host.
