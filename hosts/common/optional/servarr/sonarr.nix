{ pkgs, config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.sonarr = {
    enable = true;
    group = "media";
    package = pkgs.sonarr;
  };

  services.caddy.virtualHosts."sonarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8989
    '';
    useACMEHost = domain;
  };
}
