default:
  @just --list

alias s := switch

rekey:
  fd secrets.nix -x sh -c 'cd {//}; agenix -r' sh

pkgs-update:
  nix run nixpkgs#nix-update -- open-webui --flake

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
  sudo nixos-rebuild switch --flake .
[linux]
boot:
  sudo nixos-rebuild boot --flake .
[linux]
update:
  nix flake update --commit-lock-file

# Garbage-collect the Nix store
gc age='7':
    nix-collect-garbage --delete-older-than {{ age }}d

# deploy to proxmox nixos VM
# (use the binary from nixpkgs to allow for using binary cache instead of rebuilding)
deploy:
  nix run github:nixos/nixpkgs/nixpkgs-unstable#deploy-rs .#nixos
