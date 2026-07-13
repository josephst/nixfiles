final: prev: {
  home-assistant-custom-components =
    let
      inherit (final.home-assistant.python3Packages) callPackage;
    in
    prev.home-assistant-custom-components
    // {
      smartrent = callPackage ../pkgsLinux/homeassistant-customcomponents/smartrent/package.nix { };
    };

}
