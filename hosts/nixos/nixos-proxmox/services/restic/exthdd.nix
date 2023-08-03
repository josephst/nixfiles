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
  age.secrets.restic-exthdd-env.file = ../../../../../secrets/resticexthdd.env.age;
  # contents:
  # HC_UUID=<uuid for healthchecks>

  age.secrets.restic-exthdd-pass.file = ../../../../../secrets/restic-exthdd.pass.age;
  # contents: password for restic repo

  services.restic.backups.exthdd = {
    initialize = false;
    passwordFile = config.age.secrets.restic-exthdd-pass.path;
    environmentFile = config.age.secrets.restic-exthdd-env.path;
    repository = "/mnt/exthdd/restic";
    inherit pruneOpts;
    inherit checkOpts;
    timerConfig = {
      OnCalendar = "*-*-* 6:00:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    backupPrepareCommand = ''
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"
    '';
    backupCleanupCommand = ''
      output=$(journalctl --unit restic-backups-exthdd.service --since=yesterday --boot --no-pager | \
        ${pkgs.coreutils}/bin/tail --bytes 100000)
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/$EXIT_STATUS" --data-raw "$output"
    '';
  };
}
