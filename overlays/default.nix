{ inputs, ... }:
{
  agenix = inputs.agenix.overlays.default;
  zig = inputs.zig.overlays.default;
  llama-cpp = inputs.llama-cpp.overlays.default;
  deploy-rs = inputs.deploy-rs.overlays.default;

  additions =
    final: _prev:
    # this adds custom pkgs in the same namespace as all other packages
    # (ie nixpkgs.recyclarr)
    import ../pkgs { pkgs = final; };

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

  modifications = final: prev: {
    deploy-rs =
      let
        pkgs = import inputs.nixpkgs { inherit (final) system; };
      in
      {
        inherit (pkgs) deploy-rs;
        inherit (prev.deploy-rs) lib;
      };
    zig_0_12 = prev.zig_0_12.overrideAttrs (_: {
      # workaround for https://github.com/NixOS/nixpkgs/issues/317055
      strictDeps = !prev.stdenv.cc.isClang;
    });
  };
}
