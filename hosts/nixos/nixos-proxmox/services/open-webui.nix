{ pkgs, config, ... }:
let
  fqdn = config.networking.fqdn;
in
{
  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "127.0.0.1";
  };

  services.caddy.virtualHosts."open-webui.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8082
      encode gzip
    '';
    useACMEHost = fqdn;
  };
}
