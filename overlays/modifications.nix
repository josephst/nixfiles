final: prev: {
  home-assistant-custom-components =
    let
      inherit (final.home-assistant.python.pkgs) callPackage;
    in
    prev.home-assistant-custom-components
    // {
      smartrent = callPackage ../pkgsLinux/homeassistant-customcomponents/smartrent/package.nix { };
    };

  zwave-js-server = prev.zwave-js-server.overrideAttrs (
    _: old: rec {
      version = "3.2.1";
      src = old.src.override {
        rev = version;
        hash = "sha256-oZA+tMYxiWc+PiPiqGEJpEa434CqNjPbutBWjXBgmhw=";
      };
      npmDeps = final.fetchNpmDeps {
        inherit src;
        hash = "sha256-1JgfXF3kNuUj0jprKBsJSPeFH6ZpqpU4lceTQm5FBgg=";
      };
    }
  );
}
