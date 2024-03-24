{
  lib,
  config,
  pkgs,
  ...
}:
let
  fqdn = config.networking.fqdn;

  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  checkOpts = [ "--with-cache" ];
in
{
  services.restic.backups.nas_maintenance = {
    initialize = false;
    user = "restic";
    environmentFile = config.age.secrets.resticLanEnv.path;
    passwordFile = config.age.secrets.resticpass.path;
    repository = "rest:https://restic.${fqdn}";
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
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/$?" --data-raw "$output"
    '';
  };
}
