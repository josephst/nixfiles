final: prev: {
  aprutil = prev.aprutil.overrideAttrs (
    old:
    let
      patches = old.patches or [ ];
      hasVendoredClangBdbPatch = final.lib.any (
        patch: builtins.baseNameOf (toString patch) == "clang-bdb.patch"
      ) patches;
    in
    final.lib.optionalAttrs hasVendoredClangBdbPatch {
      # TODO: Remove this override once NixOS/nixpkgs#513395 reaches nixpkgs-unstable.
      patches =
        final.lib.filter (patch: builtins.baseNameOf (toString patch) != "clang-bdb.patch") patches
        ++ [
          # Fix incorrect Berkeley DB detection with newer versions of clang due to implicit `int` on main errors.
          (final.fetchpatch {
            url = "https://github.com/apache/apr-util/commit/2d838ff7319bd384a0b177f40ac19c4b6c81436d.patch?full_index=1";
            hash = "sha256-/N6V5D1d9R6AVjHUwy3Ne839D3ZSsF3Hpn8W9sx1sXM=";
            excludes = [ "CHANGES" ];
          })
          # Fix error with missing function prototype.
          (final.fetchpatch {
            url = "https://github.com/apache/apr-util/commit/e67caa006c75181b45b761cd50294cb3c8e18f1a.patch?full_index=1";
            hash = "sha256-fwKT7mGPHIgJ5uG/KAOOE/38FSNfow+GJgHCxcp9mgI=";
          })
        ];
    }
  );

  home-assistant-custom-components =
    let
      inherit (final.home-assistant.python.pkgs) callPackage;
    in
    prev.home-assistant-custom-components
    // {
      smartrent = callPackage ../pkgsLinux/homeassistant-customcomponents/smartrent/package.nix { };
    };

  # zwave-js-server = prev.zwave-js-server.overrideAttrs (
  #   _: old: rec {
  #     version = "3.2.1";
  #     src = old.src.override {
  #       rev = version;
  #       hash = "sha256-oZA+tMYxiWc+PiPiqGEJpEa434CqNjPbutBWjXBgmhw=";
  #     };
  #     npmDeps = final.fetchNpmDeps {
  #       inherit src;
  #       hash = "sha256-1JgfXF3kNuUj0jprKBsJSPeFH6ZpqpU4lceTQm5FBgg=";
  #     };
  #   }
  # );

}
