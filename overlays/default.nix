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
      version = "unstable-2023-04-07";
      pname = "lego";
      src = prev.fetchFromGitHub {
        owner = "go-acme";
        repo = pname;
        rev = "1a16d1ab9b275836ce9fc45ea7871ab4d3811879";
        sha256 = "sha256-ggkeq2ccw0UyxyeMlxuMbEF0dCuyKgirc06m0MmsApw=";
      };
    in (prev.lego.override rec {
      buildGoModule = args:
        prev.buildGoModule (args
          // {
            vendorHash = "sha256-6dfwAsCxEYksZXqSWYurAD44YfH4h5p5P1aYZENjHSs=";
            inherit src version;
          });
    });
  };
}
