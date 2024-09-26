{ pkgs, config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.plex = {
    enable = true;
    group = "media";
    package = pkgs.plex;
    openFirewall = true;
  };

  services.caddy.virtualHosts."plex.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:32400
      encode gzip
    '';
    useACMEHost = domain;
  };

  systemd.services.plex = {
    serviceConfig = {
      TimeoutStopSec = 5;
    };
  };
}
