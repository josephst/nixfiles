{
  config,
  pkgs,
  ...
}: let
  uuid = "9c9fd8af-016b-4cc8-b4f9-3c25aeeb0b8e";
  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  checkOpts = ["--read-data-subset 500M" "--with-cache"];
in {
  # config .env file containing RESTIC_PASSWORD=...
  age.secrets.resticb2env.file = ../../../../../secrets/resticb2.env.age;
  age.secrets.resticpass.file = ../../../../../secrets/restic.pass.age;
  age.secrets.rcloneConf.file = ../../../../../secrets/rcloneConf.age;

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
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/${uuid}/start"
      ${pkgs.rclone}/bin/rclone sync -v $RCLONE_LOCAL $RCLONE_REMOTE --transfers=16
    '';
    backupCleanupCommand = ''
      output=$(journalctl --unit restic-backups-b2.service --since=yesterday --boot --no-pager | \
        ${pkgs.coreutils}/bin/tail --bytes 100000)
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/${uuid}/$EXIT_STATUS" --data-raw "$output"
    '';
  };
}
