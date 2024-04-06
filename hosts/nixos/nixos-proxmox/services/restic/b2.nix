{ config, pkgs, ... }:
let
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
  localPath = "/storage/restic";
in
{
  services.restic.backups.b2 = {
    initialize = false;
    user = "restic";
    # env file contains $RCLONE_REMOTE, HD_UUID, and RCLONE_CONFIG_B2_{TYPE,ACCOUNT,KEY,HARD_DELETE)} options
    environmentFile = config.age.secrets.resticb2env.path;
    # password of restic repo
    passwordFile = config.age.secrets.restic-localstorage-pass.path;
    repository = "rclone:$RCLONE_REMOTE";
    inherit pruneOpts;
    inherit checkOpts;
    timerConfig = {
      OnCalendar = "*-*-* 3:00:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    backupPrepareCommand = ''
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"

      # copy local backup to Backblaze B2
      # (restic doesn't actually back up any additional files with this job, just syncs/checks/prunes)
      ${pkgs.rclone}/bin/rclone sync -v ${localPath} $RCLONE_REMOTE --transfers=16
    '';
    backupCleanupCommand = ''
      output=$(journalctl --unit restic-backups-b2.service --since=yesterday --boot --no-pager | \
        ${pkgs.coreutils}/bin/tail --bytes 100000)
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/$?" --data-raw "$output"
    '';
  };
}
