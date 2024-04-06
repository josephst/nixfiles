{ config, ... }:
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
in
{
  imports = [./rcloneRemoteDir.nix]; # sets config.age.secrets.rcloneRemoteDir.path

  # checks the repo on B2, no actual backing up performed
  services.restic.backups.b2 = {
    initialize = false;
    user = "restic";
    passwordFile = config.age.secrets.restic-localstorage-pass.path; # remote has same password as local
    repositoryFile = config.age.secrets.b2WithRclone.path;
    rcloneConfigFile = config.age.secrets.rcloneConf.path;
    inherit pruneOpts;
    inherit checkOpts;

    timerConfig = {
      OnCalendar = "12:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
