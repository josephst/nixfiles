{ inputs, ... }:
let
  channels = final: _prev: {
    # Keep a stable package set available as an escape hatch when an unstable
    # package regresses, even when no package currently consumes it.
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  # Add repository-local packages to the main package namespace.
  additions = import ./additions.nix;

  # modify the default nixpkgs set
  modifications = import ./modifications.nix;
in
{
  default =
    final: prev: (additions final prev) // (channels final prev) // (modifications final prev);
}
