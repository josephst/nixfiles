default:
  @just --list

alias s := switch

[macos]
switch:
  darwin-rebuild switch --flake .

[linux]
switch:
  sudo nixos-rebuild switch --flake .

# Garbage-collect the Nix store
gc age='7':
    nix-collect-garbage --delete-older-than {{ age }}d

# deploy to proxmox nixos VM
deploy:
  nix run github:serokell/deploy-rs .#nixos
