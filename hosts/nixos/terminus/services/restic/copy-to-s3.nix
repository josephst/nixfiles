{ config, pkgs, ... }:
let
  localPath = "/storage/restic";

  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  checkOpts = [
    "--read-data-subset 500M"
    "--with-cache"
  ];
in
{
  age.secrets.resticb2env.file = ../../secrets/restic/b2.env.age;
  age.secrets.rcloneConf.file = ../../secrets/rclone.conf.age;
  age.secrets.rclone-sync.file = ../../secrets/restic/rclone-sync.env.age;

  # copy local Restic repo to S3-compatible repo
  services.rclone-sync.b2 = {
    enable = true;
    dataDir = localPath;
    rcloneCommand = "copy";
    environmentFile = config.age.secrets.rclone-sync.path;
    rcloneConfFile = config.age.secrets.rcloneConf.path;
    extraRcloneArgs = [
      "--transfers=32"
      "--b2-hard-delete"
      "--fast-list"
    ];

    timerConfig = {
      OnCalendar = "06:00";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };

  # Apply retention and integrity checks to the B2 repository once a month;
  # this does not create any snapshots.
  services.restic.backups.b2 = {
    initialize = false;
    environmentFile = config.age.secrets.resticb2env.path;
    inherit pruneOpts;
    inherit checkOpts;

    backupPrepareCommand = ''
      # remove old locks
      ${pkgs.restic}/bin/restic unlock || true
    '';

    timerConfig = {
      # Run after the daily 06:00 Rclone copy window.
      OnCalendar = "*-*-01 08:00";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };

  # If first-of-month timers are caught up together after downtime, preserve
  # local maintenance -> Rclone copy -> B2 maintenance ordering.
  systemd.services.rclone-sync-b2.after = [ "restic-backups-local-maintenance.service" ];
  systemd.services.restic-backups-b2.after = [ "rclone-sync-b2.service" ];
}
