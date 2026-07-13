{
  config,
  ...
}:
let
  inherit (config.networking) domain;
in
{
  services = {
    backrest = {
      enable = true;
      bindAddress = "127.0.0.1";
    };
    caddy.virtualHosts."backrest.${domain}" = {
      # TODO: Remove the HTTP sync-only fallback once this host runs Backrest >= 1.14.1.
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
}
