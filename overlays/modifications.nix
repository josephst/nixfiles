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

  zsh = prev.zsh.overrideAttrs (
    old:
    let
      patches = old.patches or [ ];
      hasSigsuspendProbePatch = final.lib.any (
        patch: builtins.baseNameOf (toString patch) == "fix-sigsuspend-probe-c23.patch"
      ) patches;
      sigsuspendProbePatch = final.writeText "fix-sigsuspend-probe-c23.patch" ''
        Prototype the K&R handler so the probe still compiles under -std=gnu23
        (selected by autoconf 2.73). Upstream removed the probe in 8dd271fdec52,
        which does not apply against 5.9 with the PCRE backports.

        https://github.com/NixOS/nixpkgs/issues/513543
        --- a/configure.ac
        +++ b/configure.ac
        @@ -2334,8 +2334,7 @@ if test x$signals_style = xPOSIX_SIGNALS; then
         #include <signal.h>
         #include <unistd.h>
         int child=0;
        -void handler(sig)
        -    int sig;
        +void handler(int sig)
         {if(sig==SIGCHLD) child=1;}
         int main() {
             struct sigaction act;
      '';
    in
    final.lib.optionalAttrs (!hasSigsuspendProbePatch) {
      # TODO: Remove this override once NixOS/nixpkgs#513971 reaches nixpkgs-unstable.
      patches = patches ++ [ sigsuspendProbePatch ];
    }
  );

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
