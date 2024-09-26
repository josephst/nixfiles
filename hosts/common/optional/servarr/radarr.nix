{ pkgs, config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.radarr = {
    enable = true;
    group = "media";
    package = pkgs.radarr;
  };

  services.caddy.virtualHosts."radarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:7878
    '';
    useACMEHost = domain;
  };
}
