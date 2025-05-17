{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.jellyfin = {
    enable = true;
    group = "media";
  };

  services.caddy.virtualHosts."jellyfin.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8096
      encode gzip
    '';
    useACMEHost = domain;
  };
}
