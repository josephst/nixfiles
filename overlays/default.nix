{inputs, ...}: {
  agenix = inputs.agenix.overlays.default;
  zig = inputs.zig.overlays.default;

  additions = final: prev:
  # this adds custom pkgs in the same namespace as all other packages
  # (ie nixpkgs.recyclarr)
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    };
  channels = final: prev: {
    # this adds nixpkgs-unstable as an overlays, available as nixpkgs.unstable.foobar
    # doesn't do much now, since we're already following unstable
    unstable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
  modifications = final: prev: rec {
    # # override lego version (ACME certificates) with newest rev from github
    # # which supports google domains
    # # TODO: delete this once v4.11 is released to nixos unstable channel
    # lego = let
    #   version = "unstable-2023-05-02";
    #   pname = "lego";
    #   src = prev.fetchFromGitHub {
    #     owner = "go-acme";
    #     repo = pname;
    #     rev = "5a70c3661d214ad2ec20158b2a4b0fd0ce2e4bb0";
    #     sha256 = "sha256-bv9IeOO3V32ZpaYq0FlFWI646Prwr/gl2dvwUUc9+Ec="; # replace with prev.lib.fakeHash for updating
    #   };
    # in (prev.lego.override rec {
    #   buildGoModule = args:
    #     prev.buildGoModule (args
    #       // {
    #         vendorHash = "sha256-6dfwAsCxEYksZXqSWYurAD44YfH4h5p5P1aYZENjHSs="; # prev.lib.fakeHash again
    #         inherit src version;
    #       });
    # });
}
