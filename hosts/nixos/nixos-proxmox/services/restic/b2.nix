{
  config,
  pkgs,
  ...
}: let
  uuid = "9c9fd8af-016b-4cc8-b4f9-3c25aeeb0b8e";
  forgetOpts = "--keep-daily 30 --keep-weekly 52 --keep-monthly 24 --keep-yearly 10 --keep-tag forever";
  checkOpts = "--read-data-subset 500M";
in {
  # config .env file containing RESTIC_PASSWORD=...
  age.secrets.resticb2env = {
    file = ../../../../../secrets/resticb2.env.age;
  };

  age.secrets.rcloneConf = {
    file = ../../../../../secrets/rcloneConf.age;
  };

  systemd.services.restic-b2-maintenance = {
    description = "Restic remote-specific tasks (rclone & restic check) on B2";
    wants = ["healthchecks@${uuid}:start:%n.service"];
    onFailure = ["healthchecks@${uuid}:failure:%n.service"];
    onSuccess = ["healthchecks@${uuid}:success:%n.service"];
    environment = {
      RCLONE_CONFIG = config.age.secrets.rcloneConf.path;
    };
    serviceConfig = {
      # User = "restic";
      # Group = "restic";
      Type = "oneshot";
      RuntimeDirectory = "restic-b2";
      CacheDirectory = "restic-b2";
      CacheDirectoryMode = "0700";
      EnvironmentFile = config.age.secrets.resticb2env.path;
      ExecStart = [
        "${pkgs.rclone}/bin/rclone sync -v $RCLONE_LOCAL $RCLONE_REMOTE --transfers=16"
        "${pkgs.restic}/bin/restic -r rclone:\$\{RCLONE_REMOTE\} forget ${forgetOpts} --prune --cache-dir=%C/restic-b2"
        "${pkgs.restic}/bin/restic -r rclone:\$\{RCLONE_REMOTE\} check ${checkOpts} --cache-dir=%C/restic-b2"
      ];

      # hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      DevicePolicy = "closed";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies= [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
  };

  systemd.timers.restic-b2-maintenance = {
    description = "Run Restic local-specific maintenance (forget, prune, check) at 2:00 AM +/- 1hr";
    timerConfig = {
      OnCalendar = "*-*-* 2:00:00";
    };
    wantedBy = ["timers.target"];
  };
}
