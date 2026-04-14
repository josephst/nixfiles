default:
  @just --list

alias s := switch

pkgs-update:
  nix run nixpkgs#nix-update -- smartrent-py --flake
  # note: next command requires having a linux x86_64 builder availbale for Nix; will fail otherwise.
  nix run nixpkgs#nix-update -- hass-smartrent --flake --system x86_64-linux

[macos]
switch:
  git add --all
  # sudo darwin-rebuild switch --flake .
  nh darwin switch .
[macos]
update:
  brew update
  nix flake update --commit-lock-file

[linux]
switch:
  git add --all
  # sudo nixos-rebuild switch --flake .
  nh os switch .
[linux]
boot:
  sudo nixos-rebuild boot --flake .
[linux]
update:
  nix flake update --commit-lock-file

# Garbage-collect the Nix store
gc age='7':
    nix-collect-garbage --delete-older-than {{ age }}d

deploy:
  # nix run nixpkgs#deploy-rs .#terminus
  # nix run nixpkgs#nixos-rebuild -- --target-host joseph@terminus --sudo switch --flake .#terminus --build-host terminus --no-reexec --use-substitutes
  nix run nixpkgs#nixos-rebuild -- --target-host joseph@anacreon --sudo switch --flake .#anacreon --build-host anacreon --no-reexec --use-substitutes
