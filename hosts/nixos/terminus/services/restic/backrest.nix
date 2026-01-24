{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.backrest = {
    enable = true;
    bindAddress = "localhost";
    readWritePaths = [
      "/storage"
    ];
  };
  services.caddy.virtualHosts."backrest.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:9898
    '';
    useACMEHost = domain;
  };
}
