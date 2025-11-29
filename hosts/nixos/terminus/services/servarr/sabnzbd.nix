{
  config,
  ...
}:
let
  inherit (config.networking) domain;
  starting_config = ''
    __version__ = 19
    __encoding__ = utf-8
    [misc]
    port = 8082
    host_whitelist = "${config.networking.hostName},sabnzbd.${domain}"
  '';
in
{
  services.sabnzbd = {
    enable = true;
    group = "media";
  };

  systemd.services.sabnzbd = {
    bindsTo = [ "storage.mount" ];
    after = [ "storage.mount" ];
  };

  services.caddy.virtualHosts."sabnzbd.${domain}" = {
    # remember to edit sabnzbd config to listen on 8082 (otherwise it won't start)
    extraConfig = ''
      reverse_proxy localhost:8082
    '';
    useACMEHost = domain;
  };

  # hardening options copied from upstream
  # https://github.com/sabnzbd/sabnzbd/blob/master/linux/sabnzbd%40.service
  systemd.services.sabnzbd.serviceConfig = {
    ProtectSystem = "full";
    DeviceAllow = [
      "/dev/null rw"
      "/dev/urandom r"
    ];
    DevicePolicy = "strict";
    NoNewPrivileges = true;
  };

  systemd.tmpfiles.settings = {
    "10-sabnzbd" = {
      "/var/lib/sabnzbd/sabnzbd.ini" = {
        f = {
          user = "sabnzbd";
          group = "media";
          mode = "0600";
          argument = starting_config;
        };
      };
      "/storage/media/usenet" = {
        d = {
          user = "sabnzbd";
          group = "media";
          mode = "0770";
        };
      };
    };
  };
}
