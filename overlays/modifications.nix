final: prev: {
  # TODO: Remove once nixpkgs-unstable includes backrest 1.14.1.
  backrest =
    let
      version = "1.14.1";
      src = prev.fetchFromGitHub {
        owner = "garethgeorge";
        repo = "backrest";
        tag = "v${version}";
        hash = "sha256-RxjPjvnKy8UM1OXRklJF/HSZ6FMiHWYQBsZ6owMJMF0=";
        leaveDotGit = true;
        postFetch = ''
          cd "$out"
          git rev-parse HEAD > $out/COMMIT
          find "$out" -name .git -print0 | xargs -0 rm -rf
        '';
      };
    in
    prev.backrest.overrideAttrs (oldAttrs: {
      inherit src version;

      vendorHash = "sha256-yadRulgtcDPthWLeTydcMol/vwriflKvDu7zgoehZCM=";

      passthru = oldAttrs.passthru // {
        frontend = oldAttrs.passthru.frontend.overrideAttrs (oldFrontendAttrs: {
          inherit src version;

          buildPhase = ''
            runHook preBuild
            export BACKREST_BUILD_VERSION=${version}
            pnpm build
            runHook postBuild
          '';

          pnpmDeps = oldFrontendAttrs.pnpmDeps.overrideAttrs (_: {
            inherit src version;
            outputHash = "sha256-y6NYFPepibiTuvPMwyc5cN3TwAc2W7RtPbCmzWDozNQ=";
          });
        });
      };
    });

  # Keep the repository-local SmartRent component compatible with its matching
  # Python library until both versions are available together in nixpkgs.
  home-assistant-custom-components =
    let
      inherit (final.home-assistant.python3Packages) callPackage;
    in
    prev.home-assistant-custom-components
    // {
      smartrent = callPackage ../pkgsLinux/homeassistant-customcomponents/smartrent/package.nix { };
    };

}
