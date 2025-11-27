# Dotfiles w/ Nix and Home Manager

🔔 [Read a blog post about this repository](https://josephstahl.com/nix-for-macos-and-a-homelab-server/)

> This is my personal Nix configuration repository managing both macOS (via nix-darwin) and NixOS systems with home-manager. While I try to keep everything working properly, use any part of this repo on your own system at your own risk! I'd recommend using this more for inspiration than exact instructions.

## Repository Structure

This flake-based configuration uses a modular architecture:

- **`modules/common/myConfig/`** - Shared configuration options and implementations
- **`modules/darwin/myConfig/`** - macOS-specific extensions
- **`modules/nixos/myConfig/`** - NixOS-specific extensions
- **`modules/home-manager/myHomeConfig/`** - User environment configuration
- **`hosts/`** - Host-specific configurations
- **`home/joseph/`** - User dotfiles and program configurations
- **`keys/`** - SSH public keys for system access and encryption
- **`secrets/`** - Age-encrypted secrets using agenix

## Quick Start

### Building and Switching
```bash
# Build and switch configuration (auto-detects platform)
just switch  # or just s

# Update flake inputs
just update

# Deploy to remote NixOS server
just deploy
```

### Common Commands
```bash
# Format and lint code
nix fmt
nix run nixpkgs#statix check .

# Garbage collect old generations
just gc [age=7]  # defaults to 7 days

# Check configuration builds correctly
nix flake check
```

## macOS Setup

### Prerequisites
1. **Generate host keys** (if they don't exist):
   ```bash
   sudo ssh-keygen -A
   ```

2. **Install Nix**: Follow the [Zero to Nix](https://zero-to-nix.com/start/install) guide

3. **Install Homebrew**:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### First-time Setup
1. Clone this repository
2. Update `flake.nix` to match your hostname and preferences
3. Configure SSH keys in `keys/default.nix`
4. Run `just switch` to build and activate the configuration

### Current System
- **Josephs-MacBook-Air** - Primary development machine

## NixOS Setup

### Current Systems
- **terminus** (x86_64-linux) - Homelab server
- **orbstack** (aarch64-linux) - Development container
- **iso-gnome** (aarch64-linux) - Live ISO image

### Remote Installation with nixos-anywhere

NixOS installation uses [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) for unattended/remote setups.

#### Basic Installation Process
1. Boot the target system with NixOS installer
2. Set password for `nixos` user: `passwd`
3. Get IP address: `ip a`
4. Install remotely from this repository

#### For existing systems (with hardware-configuration.nix):
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#terminus \
  --target-host nixos@<IP_ADDRESS> \
  --build-on remote \
```

#### For new systems (generate hardware config):
```bash
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hosts/nixos/terminus/hardware-configuration.nix \
  --flake .#terminus \
  --target-host nixos@<IP_ADDRESS> \
  --build-on remote \
```

> **Note**: `--build-on-remote` is necessary for cross-architecture builds.
> Ensure disk setup is configured with `disko` (see examples in `hosts/nixos/*/disko.nix`).

### Secrets Management with Agenix

This repository uses [agenix](https://github.com/ryantm/agenix) for secrets management.

#### For systems with secrets, add these flags:
- `--copy-host-keys` - Copies SSH host keys to the new system
- `--extra-files "$temp"` - Copies user SSH keys for secret decryption

#### Setting up user keys for new systems:
```bash
temp=$(mktemp -d)
install -d -m755 "$temp/home/joseph/.ssh"

# Get keys from 1Password or generate new ones
op read "op://Private/<item>/private key" > "$temp/home/joseph/.ssh/id_ed25519"
op read "op://Private/<item>/public key" > "$temp/home/joseph/.ssh/id_ed25519.pub"

# Set correct permissions
chmod 600 "$temp/home/joseph/.ssh/id_ed25519"*
```

#### Important notes:
- Re-key all secrets with new keys before installation

## Post-Installation Configuration

### Essential Setup

#### Tailscale
```bash
tailscale up --ssh
```
- Update dynamic DNS records with Tailscale IP for external access
- Ensures devices on the Tailnet can resolve hostnames via public DNS

### Service-Specific Configuration

The terminus server runs various self-hosted services. Some require manual setup:

#### Media Services (Servarr Stack)
- **Jellyfin**: Access web interface for initial media library setup
- **Sonarr/Radarr**: Configure indexers and download clients
- **Prowlarr**: Set up indexer connections
- **SABnzbd**:
  - Edit `/var/lib/sabnzbd/sabnzbd.ini`
  - Add `sabnzbd.terminus.josephstahl.com` to `host_whitelist`
  - Configure port (default: 8082 to avoid conflicts with Unifi on 8080)

#### Home Assistant
- Configure devices and integrations via web interface
- Zigbee and Z-Wave devices managed through dedicated containers

#### Monitoring
- **Netdata**: System monitoring with automatic configuration
- **Homepage**: Dashboard aggregating all services

### Development Tools
- **VS Code Server**: Remote development access
- **Ollama**: Local LLM inference server
## Customization

To adapt this configuration for your own use:

1. **Update personal information**:
   - Change user details in `flake.nix` commonConfig
   - Update SSH keys in `keys/default.nix`
   - Modify email and name in git configuration

2. **Host configuration**:
   - Add your systems to `nixosConfigurations` or `darwinConfigurations`
   - Create host-specific configs in `hosts/`
   - Update networking and hardware configurations

3. **Services**:
   - Enable/disable services in host configurations
   - Modify service configurations in `hosts/*/services/`
   - Update domain names and certificates

4. **Secrets**:
   - Re-key all secrets with your own SSH keys
   - Update secret paths in configurations
   - Configure agenix for your key management

## Troubleshooting

- Always run `git add --all` before nix operations
- Use `nix flake check` to validate configurations
- Review systemd logs for service problems: `journalctl -u <service>`
