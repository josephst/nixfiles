{
  pkgs,
  lib,
  ...
}:
let
  fs = lib.fileset;
  homepage-assets = pkgs.stdenv.mkDerivation {
    name = "anacreon-homepage-assets";
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

    tailscale.serve.services.anacreon-home = {
      endpoints = {
        "tcp:443" = "http://127.0.0.1:8080";
      };
    };
  };
}
