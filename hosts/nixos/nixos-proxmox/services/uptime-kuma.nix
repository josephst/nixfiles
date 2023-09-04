{
  config,
  pkgs,
  ...
}: let
  fqdn = config.networking.fqdn
in {
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "3001"; # this is default port
    };
  };

  services.caddy.virtualHosts."uptime.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:3001
    '';
    useACMEHost = fqdn;
  };
}
