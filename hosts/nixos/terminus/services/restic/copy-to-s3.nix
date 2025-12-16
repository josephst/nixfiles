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
    environmentFile = config.age.secrets.rclone-sync.path;
    rcloneConfFile = config.age.secrets.rcloneConf.path;

    timerConfig = {
      OnCalendar = "16:00";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };

  # checks the repo on B2, no actual backing up performed
  services.restic.backups.b2 = {
    initialize = false;
    environmentFile = config.age.secrets.resticb2env.path;
    inherit pruneOpts;
    inherit checkOpts;

    backupPrepareCommand = ''
      # remove old locks
      ${pkgs.restic}/bin/restic unlock || true
    '';

    timerConfig = null; # no automatic run; instead, triggered after rclone-sync finishes
  };

  systemd.services.rclone-sync-b2.onSuccess = [ "restic-backups-b2.service" ];
}
