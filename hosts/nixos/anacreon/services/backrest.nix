{
  config,
  ...
}:
let
  inherit (config.networking) domain;
  siteHost = "backrest.${config.networking.hostName}.${domain}";
in
{
  services = {
    backrest = {
      enable = true;
      bindAddress = "127.0.0.1";
    };
    caddy.virtualHosts.${siteHost} = {
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
  };
}
