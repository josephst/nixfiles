{ inputs, ... }:
let
  channels = final: _prev: {
    # this adds nixpkgs-unstable as an overlays, available as nixpkgs.unstable.foobar
    # doesn't do much now, since we're already following unstable
    unstable = import inputs.nixpkgs {
      inherit (final) system;
      config.allowUnfree = true;
    };
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
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
