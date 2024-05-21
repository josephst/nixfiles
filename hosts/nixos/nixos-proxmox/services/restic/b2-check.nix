{
  config,
  lib,
  pkgs,
  ...
}:
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
  imports = [ ./rcloneRemoteDir.nix ]; # sets config.age.secrets.rcloneRemoteDir.path

  # checks the repo on B2, no actual backing up performed
  services.restic.backups.b2 = {
    initialize = false;
    user = "restic";
    environmentFile = config.age.secrets.resticb2env.path;
    passwordFile = config.age.secrets.restic-localstorage-pass.path; # remote has same password as local
    repositoryFile = config.age.secrets.b2WithRclone.path;
    rcloneConfigFile = config.age.secrets.rcloneConf.path;
    inherit pruneOpts;
    inherit checkOpts;

    backupPrepareCommand = ''
      # preStart
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"
    '';

    timerConfig = {
      OnCalendar = "12:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # TODO: refactor into a mkResticBackup script that's shared between LocalStorage and B2?
  systemd.services."restic-backups-b2" = {
    onSuccess = [ "restic-notify-b2@success.service" ];
    onFailure = [ "restic-notify-b2@failure.service" ];
  };

  systemd.services."restic-notify-b2@" = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.resticb2env.path; # contains heathchecks.io UUID
      User = "restic"; # to read env file
      ExecStart = "${./healthcheck.sh} $HC_UUID $MONITOR_EXIT_STATUS $MONITOR_UNIT";
    };
    path = [
      pkgs.bash
      pkgs.curl
    ];
  };
}
