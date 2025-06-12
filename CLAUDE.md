# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based configuration repository using flakes that manages:
- macOS systems via nix-darwin
- NixOS systems (homelab and VMs)
- Home-manager configurations for user environments
- Custom packages and overlays

The architecture follows a modular pattern where common configuration is shared between platforms through the `modules/common/` directory, with platform-specific modules in `modules/darwin/` and `modules/nixos/`.

## Key Commands

### Development and Building
```bash
# Build and switch configuration (auto-detects platform)
just switch  # or just s

# Update flake inputs
just update

# Format code
nix fmt

# Lint and check code quality
nix run nixpkgs#statix check .
nix run nixpkgs#deadnix .

# Garbage collect old generations
just gc [age=7]  # defaults to 7 days
```

### Platform-Specific Operations
```bash
# macOS (nix-darwin)
sudo darwin-rebuild switch --flake .

# NixOS
sudo nixos-rebuild switch --flake .
sudo nixos-rebuild boot --flake .  # for next reboot

# Deploy to remote NixOS (terminus server)
just deploy
```

### Testing and Development
```bash
# Enter development shell
nix develop

# Check syntax and make sure files can be parsed by Nix
nix flake check

# Update custom packages
just pkgs-update

# Test configuration without switching
nix build .#darwinConfigurations.Josephs-MacBook-Air.system
nix build .#nixosConfigurations.terminus.config.system.build.toplevel
```

### Secrets Management (agenix)
```bash
# Edit secrets
agenix -e secrets/example.age

# Re-key all secrets (after adding new SSH keys)
agenix -r

# Re-key specific secret with specific identity
agenix -r -i ~/.ssh/id_ed25519 secrets/example.age
```

### Debugging Build Failures
```bash
# Show build logs for failed derivation
nix log /nix/store/<derivation-hash>

# Get detailed derivation info
nix show-derivation .#nixosConfigurations.terminus.config.system.build.toplevel

# Debug build environment (enter shell with build inputs)
nix develop .#nixosConfigurations.terminus.config.system.build.toplevel

# Check what would be built/downloaded
nix build --dry-run .#darwinConfigurations.Josephs-MacBook-Air.system

# Force rebuild ignoring cache
nix build --rebuild .#nixosConfigurations.terminus.config.system.build.toplevel

# Compare current system with new configuration
nvd diff /nix/var/nix/profiles/system result
```

## Architecture Overview

### Module System
- `modules/common/myConfig/` - Shared configuration options and implementations
- `modules/darwin/myConfig/` - macOS-specific extensions to common config
- `modules/nixos/myConfig/` - NixOS-specific extensions to common config
- `modules/home-manager/myHomeConfig/` - User environment configuration

### Key Files
- `flake.nix` - Main entry point defining all systems and their configurations
- `justfile` - Command runner with platform-aware tasks
- `lib/helpers.nix` - Helper functions for system creation
- `overlays/` - Custom package modifications and additions
- `secrets/` - Age-encrypted secrets using agenix

### System Definitions
Systems are defined in `flake.nix` using helper functions:
- `mkNixos` for NixOS systems (terminus, orbstack, iso images)
- `mkDarwin` for macOS systems (Josephs-MacBook-Air)
- a few options are definied in the `hostSpec` module which define system configurations and options

### Secrets Management
Uses agenix for encrypted secrets. Key locations:
- `secrets/` - System-level secrets
- `home/joseph/secrets/` - User-level secrets
- `keys/` - SSH public keys for encryption

### Home Manager Integration
User environments are managed through home-manager with configurations in `home/joseph/`. The base configuration includes development tools, shell setup, and dotfiles.

## Important Notes

- Always run `git add --all` before switching (automated in justfile)
- Use `sudo` for system-level rebuilds on both platforms
- Before running any nix commands, run `git add --all` so that Nix detects new and changed files.
- Run `nix flake check` to make sure changes don't break builds
- Run `nix fmt` to format files after edits
- The repository supports cross-platform builds and remote deployment
- Binary caches are configured to speed up builds
- State versions are carefully managed and should not be changed lightly
