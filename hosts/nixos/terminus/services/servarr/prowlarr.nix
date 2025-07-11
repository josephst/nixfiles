{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = 9696;
      };
      authentication = {
        method = "External";
      };
    };
  };

  services.caddy.virtualHosts."prowlarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:9696
    '';
    useACMEHost = domain;
  };
}
