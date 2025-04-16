default:
  @just --list

alias s := switch

pkgs-update:
  nix run nixpkgs#nix-update -- smartrent-py --flake
  nix run nixpkgs#nix-update -- hass-smartrent --flake --system aarch64-linux

[macos]
switch:
  git add --all
  darwin-rebuild switch --flake .
[macos]
update:
  brew update
  nix flake update --commit-lock-file

[linux]
switch:
  git add --all
  nixos-rebuild switch --flake . --sudo
[linux]
boot:
  nixos-rebuild boot --flake . --sudo
[linux]
update:
  nix flake update --commit-lock-file

# Garbage-collect the Nix store
gc age='7':
    nix-collect-garbage --delete-older-than {{ age }}d

# deploy to proxmox nixos VM
# (use the binary from nixpkgs to allow for using binary cache instead of rebuilding)
deploy:
  nix run nixpkgs#deploy-rs .#terminus
