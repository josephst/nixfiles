{
  pkgs,
  lib,
  config,
  ...
}:
let
  fs = lib.fileset;
  siteHost = "home.${config.hostSpec.tailnet}";
  homepage-assets = pkgs.stdenv.mkDerivation {
    name = "anacreon-homepage-assets";
    src = fs.toSource {
      root = ./.;
      fileset = fs.unions [
        ./index.html
        ./style.css
      ];
    };
    installPhase = ''
      mkdir -p $out
      cp index.html style.css $out/
    '';
  };
in
{
  services = {
    caddy.virtualHosts.":8080" = {
      listenAddresses = [ "127.0.0.1" ];
      extraConfig = ''
        root * ${pkgs.compressDrvWeb homepage-assets { }}
        file_server {
          precompressed br gzip
        }
      '';
    };
    caddy.virtualHosts."${siteHost}" = {
      extraConfig = ''
        root * ${pkgs.compressDrvWeb homepage-assets { }}
        file_server {
          precompressed br gzip
        }
      '';
    };
  };
}
