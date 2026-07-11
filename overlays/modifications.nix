final: prev: {
  home-assistant-custom-components =
    let
      inherit (final.home-assistant.python3Packages) callPackage;
    in
    prev.home-assistant-custom-components
    // {
      smartrent = callPackage ../pkgsLinux/homeassistant-customcomponents/smartrent/package.nix { };
    };

  starship = prev.starship.overrideAttrs (oldAttrs: {
    # TODO: Remove once nixpkgs commit 883e799eb2843d1438a5ce76ed8ac4a924cf6ce5 reaches nixpkgs-unstable.
    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [ ])
      ++ final.lib.optionals final.stdenv.hostPlatform.isDarwin [
        final.llvmPackages.lld
      ];

    env =
      (oldAttrs.env or { })
      // final.lib.optionalAttrs final.stdenv.hostPlatform.isDarwin {
        NIX_CFLAGS_LINK = "-fuse-ld=lld";
      };
  });

}
