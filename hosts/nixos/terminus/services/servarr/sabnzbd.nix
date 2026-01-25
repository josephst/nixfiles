{
  config,
  ...
}:
let
  inherit (config.networking) domain;
in
{
  services.sabnzbd = {
    enable = true;
    group = "media";
    allowConfigWrite = true; # allow writing sabnzbd.ini (for quota tracking)
    settings = {
      misc = {
        port = 8082;
        host_whitelist = "${config.networking.hostName},sabnzbd.${domain}";
      };
    };
  };

  systemd.services.sabnzbd = {
    bindsTo = [ "storage.mount" ];
    after = [ "storage.mount" ];
  };

  services.restic.backups.system-backup.paths = [
    "/var/lib/sabnzbd/"
  ];

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
