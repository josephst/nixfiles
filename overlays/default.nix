{inputs, ...}: {
  agenix = inputs.agenix.overlays.default;
  zig = inputs.zig.overlays.default;
  additions = final: prev:
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    };
  unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
  modifications = final: prev: {
    # override lego version (ACME certificates) with newest rev from github
    # which supports google domains
    # TODO: delete this once v4.11 is released to nixos unstable channel
    lego = let
      version = "unstable-2023-05-02";
      pname = "lego";
      src = prev.fetchFromGitHub {
        owner = "go-acme";
        repo = pname;
        rev = "5a70c3661d214ad2ec20158b2a4b0fd0ce2e4bb0";
        sha256 = "sha256-bv9IeOO3V32ZpaYq0FlFWI646Prwr/gl2dvwUUc9+Ec="; # replace with prev.lib.fakeHash for updating
      };
    in (prev.lego.override rec {
      buildGoModule = args:
        prev.buildGoModule (args
          // {
            vendorHash = "sha256-6dfwAsCxEYksZXqSWYurAD44YfH4h5p5P1aYZENjHSs="; # prev.lib.fakeHash again
            inherit src version;
          });
    });
  };
}
