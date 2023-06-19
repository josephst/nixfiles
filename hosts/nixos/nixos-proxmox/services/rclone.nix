{
  config,
  pkgs,
  ...
}: let
  port = toString 8081;
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  age.secrets.rcloneConf = {
    file = ../../../../secrets/rcloneConf.age;
  };

  systemd.services.rclone-restic-server = {
    description = "Serve NAS restic backup directory using Rclone";
    after = ["syslog.target" "network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      # User = "restic";
      # Group = "restic";
      LoadCredential= ["RCLONE_CONF:${config.age.secrets.rcloneConf.path}"];
      ExecStart = "${pkgs.rclone}/bin/rclone --config \${CREDENTIALS_DIRECTORY}/RCLONE_CONF serve restic --addr :${port} nas:/scratch/Restic";
      Restart = "on-abnormal";
      RestartSec = 5;
      # Makes created files group-readable, but inaccessible by others
      UMask = 027;

      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      DevicePolicy = "closed";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
  };
  services.caddy.virtualHosts."restic.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8081
    '';
    useACMEHost = fqdn;
  };
}
