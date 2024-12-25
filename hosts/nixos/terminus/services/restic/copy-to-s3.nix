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
  # copy local Restic repo to S3-compatible repo
  services.rclone-sync = {
    enable = true;
    dataDir = localPath;
    environmentFile = config.age.secrets.resticb2env.path;
    rcloneConfFile = config.age.secrets.rcloneConf.path;
    pingHealthchecks = true;

    timerConfig = {
      OnCalendar = "06:00";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };

  # checks the repo on B2, no actual backing up performed
  services.restic.backups.b2 = {
    initialize = false;
    environmentFile = config.age.secrets.resticb2env.path;
    repositoryFile = config.age.secrets.resticb2bucketname.path; # using s3-compatible API on Backblaze B2
    passwordFile = config.age.secrets.restic-localstorage-pass.path; # remote has same password as local
    inherit pruneOpts;
    inherit checkOpts;

    # TODO:
    # healthchecksFile = ...

    backupPrepareCommand = ''
      # remove old locks
      ${pkgs.restic}/bin/restic unlock || true
    '';

    timerConfig = {
      OnCalendar = "12:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
