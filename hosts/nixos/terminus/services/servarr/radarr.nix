{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.radarr = {
    enable = true;
    group = "media";
    settings = {
      server = {
        port = 7878;
      };
      authentication = {
        method = "External";
        type = "DisabledForLocalAddresses";
      };
    };
  };

  systemd.services.radarr = {
    bindsTo = [ "storage-media.mount" ];
    after = [ "storage-media.mount" ];
  };

  services.caddy.virtualHosts."radarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:7878
    '';
    useACMEHost = domain;
  };
}
