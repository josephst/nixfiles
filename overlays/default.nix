{ inputs, ... }:
let
  channels = final: _prev: {
    # this adds nixpkgs-unstable as an overlays, available as nixpkgs.unstable.foobar
    # doesn't do much now, since we're already following unstable
    unstable = import inputs.nixpkgs {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
    # Keep a stable package set available as an escape hatch when an unstable
    # package regresses, even when no package currently consumes it.
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  # add user-defined packages
  additions = import ./additions.nix;

  # modify the default nixpkgs set
  modifications = import ./modifications.nix;
in
{
  default =
    final: prev: (additions final prev) // (channels final prev) // (modifications final prev);
}
