default:
  @just --list

alias s := switch

rekey:
  fd secrets.nix -x sh -c 'cd {//}; agenix -r' sh

[macos]
switch:
  darwin-rebuild switch --flake .

[linux]
switch:
  sudo nixos-rebuild switch --flake .
boot:
  sudo nixos-rebuild boot --flake .

# Garbage-collect the Nix store
gc age='7':
    nix-collect-garbage --delete-older-than {{ age }}d

# deploy to proxmox nixos VM
# (use the binary from nixpkgs to allow for using binary cache instead of rebuilding)
deploy:
  nix run github:nixos/nixpkgs/nixpkgs-unstable#deploy-rs .#nixos

# update flakes
update:
  nix flake update --commit-lock-file
