{ config, lib, ... }:
let
  port = toString 8081;
  inherit (config.networking) domain;
in
{
  services.restic.server = {
    enable = true;
    dataDir = "/storage/restic";
    listenAddress = "127.0.0.1:${port}";
    extraFlags = [ "--no-auth" ]; # auth managed by tailscale
  };

  services.caddy.virtualHosts = lib.mkIf config.services.restic.server.enable {
    "restic.${domain}" = {
      extraConfig = ''
        @tailscale remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
        handle @tailscale {
          reverse_proxy http://localhost:${port}
        }
        respond 403
      '';
      useACMEHost = domain;
    };
  };

  systemd.tmpfiles.rules = lib.mkIf config.services.restic.server.enable [
    "d /storage/restic - restic restic"
  ];
}
