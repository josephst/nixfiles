{
  config,
  pkgs,
  ...
}: let
  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  checkOpts = ["--read-data-subset 500M" "--with-cache"];
in {
  age.secrets.resticb2env.file = ../../../../../secrets/resticb2.env.age;
  # contents:
  # RCLONE_LOCAL=<rclone path>
  # RCLONE_REMOTE=<rclone path>
  # RESTIC_REPOSITORY=<restic path to b2 repository (ie rclone:b2:...)
  # HC_UUID=<uuid for healthchecks>

  age.secrets.resticpass.file = ../../../../../secrets/restic.pass.age;
  # contents: password for restic repo

  age.secrets.rcloneConf.file = ../../../../../secrets/rcloneConf.age;
  # contents: rclone.conf file contents with NAS and B2 access info

  services.restic.backups.b2 = {
    initialize = false;
    environmentFile = config.age.secrets.resticb2env.path;
    passwordFile = config.age.secrets.resticpass.path;
    rcloneConfigFile = config.age.secrets.rcloneConf.path;
    repository = "rclone:\$\{RCLONE_REMOTE\}";
    inherit pruneOpts;
    inherit checkOpts;
    timerConfig = {
      OnCalendar = "*-*-* 3:00:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    backupPrepareCommand = ''
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"
      ${pkgs.rclone}/bin/rclone sync -v $RCLONE_LOCAL $RCLONE_REMOTE --transfers=16
    '';
    backupCleanupCommand = ''
      output=$(journalctl --unit %n --since=yesterday --boot --no-pager | \
        ${pkgs.coreutils}/bin/tail --bytes 100000)
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/$EXIT_STATUS" --data-raw "$output"
    '';
  };
}
