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
      ExecStart = "${pkgs.rclone}/bin/rclone --config ${config.age.secrets.rcloneConf.path} serve restic --addr :${port} nas:/scratch/Restic";
      Restart = "on-abnormal";
      RestartSec = 5;
      # Makes created files group-readable, but inaccessible by others
      UMask = 027;

      # If your system doesn't support all of the features below (e.g. because of
      # the use of an older version of systemd), you may wish to comment-out
      # some of the lines below as appropriate.
      # CapabilityBoundingSet = ;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = "yes";
      PrivateTmp = "yes";
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectSystem = "strict";
      ProtectHome = "yes";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectHostname = true;
      RemoveIPC = true;
      RestrictNamespaces = true;
      RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
    };
  };
  services.caddy.virtualHosts."restic.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8081
    '';
    useACMEHost = fqdn;
  };
}
