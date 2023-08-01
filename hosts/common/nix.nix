{ lib, stdenv, pkgs, ... }:
{
  # Use a version of Nix that works
  # nix.package = pkgs.nixVersions.nix_2_16;

  # Fallback quickly if substituters are not available.
  nix.settings.connect-timeout = 5;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # The default at 10 is rarely enough.
  nix.settings.log-lines = lib.mkDefault 25;

  # Avoid disk full issues
  nix.settings.max-free = lib.mkDefault (1000 * 1000 * 1000);
  nix.settings.min-free = lib.mkDefault (128 * 1000 * 1000);

  # Avoid copying unnecessary stuff over SSH
  nix.settings.builders-use-substitutes = true;

  # garbage collection
  nix.gc.automatic = true;
  nix.gc.interval = if stdenv.isLinux then "weekly" else { Hour = 12; Minute = 15; };
  nix.gc.options = "--delete-older-than 30d";
}
