{ inputs, ... }:
{
  agenix = inputs.agenix.overlays.default;
  zig = inputs.zig.overlays.default;
  llama-cpp = inputs.llama-cpp.overlays.default;

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

  security = _final: _prev: {
    # for https://github.com/NixOS/nixpkgs/pull/300028, but causes HUGE rebuild
    # xz = prev.xz.overrideAttrs (old: {
    #   version = inputs.nixpkgs-staging.legacyPackages.${final.system}.xz.version;
    #   src = inputs.nixpkgs-staging.legacyPackages.${final.system}.xz.src;
    # });
  };

  # add user-defined packages
  additions = import ./additions.nix;

  # modify the default nixpkgs set
  modifications = import ./modifications.nix;
}
