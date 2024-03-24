{ pkgs, config, ... }:
let
  fqdn = config.networking.fqdn;
in
{
  services.prowlarr = {
    enable = true;
  };

  services.caddy.virtualHosts."prowlarr.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:9696
    '';
    useACMEHost = fqdn;
  };
}
