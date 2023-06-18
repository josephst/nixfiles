{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  resticRepo = "rest:https://restic.${fqdn}";
  uuid = "f7536950-d7a4-41f1-b1c2-959f0cf40fd3";

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
  age.secrets.resticpass.file = ../../../../../secrets/restic.pass.age;

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
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/${uuid}/start"
    '';
    backupCleanupCommand = ''
      # TODO: try to send logs?
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/${uuid}"
    '';
  };
}
