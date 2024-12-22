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
        reverse_proxy http://localhost:${port}
      '';
      useACMEHost = domain;
    };
  };

  systemd.tmpfiles.rules = lib.mkIf config.services.restic.server.enable [
    "d /storage/restic restic restic"
  ];
}
