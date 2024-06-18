{ config, ... }:
let
  port = toString 8081;
  inherit (config.networking) fqdn;
in
{
  services.restic.server = {
    enable = true;
    dataDir = "/storage/restic";
    listenAddress = port;
    extraFlags = [ "--no-auth" ]; # auth managed by tailscale
  };

  systemd.tmpfiles.rules = [ "d  ${config.services.restic.server.dataDir}  700 restic  restic  -" ];

  services.caddy.virtualHosts."restic.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${port}
    '';
    useACMEHost = fqdn;
  };
}
