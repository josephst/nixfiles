final: prev:
# Add repository-local packages to the main package namespace.
(import ../pkgs { pkgs = final; })
// prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux (import ../pkgsLinux { pkgs = final; })
