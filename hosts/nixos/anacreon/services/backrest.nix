{
  config,
  lib,
  ...
}:
let
  inherit (config.networking) domain;
  tailscaleServe = lib.getExe config.services.tailscale.package;
in
{
  services = {
    backrest = {
      enable = true;
      bindAddress = "127.0.0.1";
    };
    caddy.virtualHosts."backrest.${domain}" = {
      # TODO: multihost with HTTPS doesn't actually work right now, will re-evaluate after 1.13.1 is released (https://github.com/garethgeorge/backrest/pull/1219)
      # may need https://github.com/garethgeorge/backrest/commit/d6415931422cb0fb3bd6d14fbe11c37bd97ccf1b to work properly
      extraConfig = ''
        @sync path /v1sync.BackrestSyncService/*
        reverse_proxy @sync h2c://127.0.0.1:9898 {
            flush_interval -1
            transport http {
                read_timeout 24h
                write_timeout 24h
            }
        }
        reverse_proxy http://127.0.0.1:9898
      '';
      useACMEHost = domain;
    };
    caddy.virtualHosts."http://backrest.${domain}" = {
      extraConfig = ''
        @sync path /v1sync.BackrestSyncService/*
        reverse_proxy @sync h2c://127.0.0.1:9898 {
            flush_interval -1
            transport http {
                read_timeout 24h
                write_timeout 24h
            }
        }
      '';
    };
  };

  systemd.services.anacreon-backrest-tailscale-serve = {
    description = "Tailscale Serve proxy for Anacreon Backrest";
    after = [
      "backrest.service"
      "tailscaled.service"
      "tailscaled-autoconnect.service"
      "tailscaled-set.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.concatStringsSep " " [
        tailscaleServe
        "serve"
        "--service=svc:backrest"
        "--https=443"
        "http://127.0.0.1:9898"
      ];
      ExecStop = "${tailscaleServe} serve clear svc:backrest";
    };
  };
}
