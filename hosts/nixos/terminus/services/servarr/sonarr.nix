{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.sonarr = {
    enable = true;
    group = "media";
    settings = {
      server = {
        port = 8989;
      };
      auth = {
        method = "External";
        type = "DisabledForLocalAddresses";
      };
    };
  };

  systemd.services.sonarr = {
    bindsTo = [ "storage-media.mount" ];
    after = [ "storage-media.mount" ];
  };

  services.caddy.virtualHosts."sonarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8989
    '';
    useACMEHost = domain;
  };
}
