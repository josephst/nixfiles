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
  modifications = final: prev: {
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
    # remove once upstreamed
    # whois = prev.whois.overrideAttrs(old: {
    #   patches = (old.patches or []) ++ [
    #     (prev.fetchpatch {
    #       url = "https://github.com/macports/macports-ports/raw/93de4e9fc1e5e8427bf98f48209e783a5e8fab57/net/whois/files/implicit.patch";
    #       extraPrefix = "";
    #       hash = "sha256-ogVylQz//tpXxPNIWIHkhghvToU1z1D1FfnUBdZLyRY=";
    #     })
    #   ];
    # });
    python311 = prev.python311.override {
      packageOverrides = python-self: python-super: {
        # remove once https://github.com/NixOS/nixpkgs/pull/273538 merged
        huggingface-hub = let
          version = "0.19.4";
        in python-super.huggingface-hub.overridePythonAttrs(old: {
          inherit version;
          src = prev.fetchFromGitHub {
            owner = "huggingface";
            repo = "huggingface_hub";
            rev = "refs/tags/v${version}";
            hash = "sha256-bK/Cg+ZFhf9TrTVlDU35cLMDuTmdH4bN/QuPVeUVDsI=";
          };
        });
        transformers = let
          version = "4.36.0";
        in python-super.transformers.overridePythonAttrs(old: {
          inherit version;
          src = prev.fetchFromGithub {
            owner = "huggingface";
            repo = "transformers";
            rev = "refs/tags/v${version}";
            hash = "sha256-aEqWH03/ghMpEmYMkNlHoPNYD1a+HIO2gSSWchQA9Qs=";
          };
        });
      };
    };
  };
}
