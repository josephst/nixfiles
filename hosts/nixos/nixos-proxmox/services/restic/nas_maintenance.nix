{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  resticRepo = "rest:https://restic.${fqdn}";

  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  checkOpts = ["--with-cache"];
in {
  age.secrets.resticLanEnv.file = ../../../../../secrets/resticLan.env.age;
  # contents: HC_UUID=<uuid>

  age.secrets.resticpass.file = ../../../../../secrets/restic.pass.age;
  # contents: repo password

  services.restic.backups.nas_maintenance = {
    initialize = false;
    environmentFile = config.age.secrets.resticLanEnv.path;
    passwordFile = config.age.secrets.resticpass.path;
    repository = resticRepo;
    # no backup paths, only run prune command
    inherit pruneOpts;
    inherit checkOpts;

    timerConfig = {
      OnCalendar = "*-*-* 1:00:00";
      Persistent = true;
    };
    backupPrepareCommand = ''
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"
    '';
    backupCleanupCommand = ''
      output=$(journalctl --unit restic-backups-nas_maintenance.service --since=yesterday --boot --no-pager | \
        ${pkgs.coreutils}/bin/tail --bytes 100000)
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/$EXIT_STATUS" --data-raw "$output"
    '';
  };
}
