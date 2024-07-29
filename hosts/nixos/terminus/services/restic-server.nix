{ config, ... }:
let
  port = toString 8081;
  listenAddress = "127.0.0.1:${port}";
  inherit (config.networking) domain;
in
{
  services.restic.server = {
    enable = true;
    dataDir = "/storage/restic";
    inherit listenAddress;
    extraFlags = [ "--no-auth" ]; # auth managed by tailscale
  };

  services.caddy.virtualHosts."restic.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${port}
    '';
    useACMEHost = domain;
  };
}
