{ config, pkgs, ... }:
let
  inherit (config.networking) domain;
  webRoot = pkgs.buildEnv {
    name = "webroot";
    paths = [
      (pkgs.writeTextDir "index.html" (builtins.readFile ./index.html))
      (pkgs.writeTextDir "new.min.css" (builtins.readFile ./new.min.css))
    ];
  };
in
{
  services.caddy.virtualHosts."${domain}" = {
    extraConfig = ''
      root * ${pkgs.compressDrvWeb webRoot { }}
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
