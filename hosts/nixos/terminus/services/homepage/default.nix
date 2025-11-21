{
  config,
  pkgs,
  lib,
  ...
}:
let
  fs = lib.fileset;
  inherit (config.networking) domain;
  homepage-assets = pkgs.stdenv.mkDerivation {
    name = "homepage-assets";
    src = fs.toSource {
      root = ./.;
      fileset = fs.unions [
        ./index.html
        ./new.min.css
      ];
    };
    installPhase = ''
      mkdir -p $out
      cp index.html new.min.css $out/
    '';
  };
in
{
  services.caddy.virtualHosts."${domain}" = {
    serverAliases = [ "${config.networking.hostName}.${config.hostSpec.tailnet}" ];
    extraConfig = ''
      root * ${pkgs.compressDrvWeb homepage-assets { }}
      file_server {
        precompressed br gzip
      }
    '';
    useACMEHost = domain;
  };

  # reject all requests to subdomains that aren't explicity configured
  services.caddy.virtualHosts."*.${domain}" = {
    extraConfig = ''
      handle {
        # Unhandled domains fall through to here,
        # but we don't want to accept their requests
        abort
      }
    '';
    useACMEHost = domain;
  };
}
