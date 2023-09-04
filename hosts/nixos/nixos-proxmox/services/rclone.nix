{
  config,
  pkgs,
  ...
}: let
  port = toString 8081;
  extHddPort = toString 8082;
  fqdn = config.networking.fqdn
in {
  age.secrets.rcloneConf = {
    file = ../../../../secrets/rclone/rclone.conf.age;
  };

  systemd.services.rclone-restic-server = {
    description = "Serve NAS restic backup directory using Rclone";
    after = ["syslog.target" "network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "restic";
      LoadCredential = ["RCLONE_CONF:${config.age.secrets.rcloneConf.path}"];
      ExecStart = "${pkgs.rclone}/bin/rclone --config \${CREDENTIALS_DIRECTORY}/RCLONE_CONF serve restic --addr :${port} nas:/scratch/Restic";
      Restart = "on-abnormal";
      RestartSec = 5;

      # Security hardening
      ReadWritePaths = []; # no read-write paths, since it's reading/writing to NAS on network
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      PrivateDevices = true;
    };
  };
  services.caddy.virtualHosts."restic.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${port}
    '';
    useACMEHost = fqdn;
  };

  systemd.tmpfiles.rules = [
    "d  /mnt/exthdd/restic  755 restic  restic"
  ];
  systemd.services.rclone-exthdd = {
    description = "Serve external HDD restic backup directory using Rclone";
    after = ["syslog.target" "network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "restic";
      Group = "restic";
      LoadCredential = ["RCLONE_CONF:${config.age.secrets.rcloneConf.path}"];
      ExecStart = "${pkgs.rclone}/bin/rclone serve restic --addr :${extHddPort} /mnt/exthdd/restic/";
      Restart = "on-abnormal";
      RestartSec = 5;

      # Security hardening
      ReadWritePaths = ["/mnt/exthdd/restic"];
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      PrivateDevices = true;
    };
  };
  services.caddy.virtualHosts."exthdd.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${extHddPort}
    '';
    useACMEHost = fqdn;
  };
}
