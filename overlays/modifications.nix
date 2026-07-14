final: prev: {
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
