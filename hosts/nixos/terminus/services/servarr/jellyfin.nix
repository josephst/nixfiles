{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.jellyfin = {
    enable = true;
    group = "media";
  };

  systemd.services.jellyfin = {
    requires = [ "storage-media.mount" ]; # requires, instead of bindsTo - can keep jellyfin running even
    # if storage is lost
    after = [ "storage-media.mount" ];
  };

  services.caddy.virtualHosts."jellyfin.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8096
      encode gzip
    '';
    useACMEHost = domain;
  };
}
