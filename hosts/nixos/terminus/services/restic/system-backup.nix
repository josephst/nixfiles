{
  config,
  pkgs,
  lib,
  ...
}:
# ROLE: to back up this machine to B2 storage using Restic
# This way, services such as Paperless are also backed up
let
  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  checkOpts = [
    "--read-data-subset 5G"
    "--with-cache"
  ];
in
{
  # backup to local repo (on HDD array), which is later copied to B2
  services.restic.backups.system-backup = {
    initialize = false;
    passwordFile = config.age.secrets.restic-localstorage-pass.path; # Repository password
    environmentFile = config.age.secrets.restic-systembackup-env.path; # HC_UUID
    repository = "rest:http://${config.services.restic.server.listenAddress}";

    paths = [
      # TODO: add to this as needed
      "/home"
      "/var/lib/paperless/backups"
    ];
    exclude = [
      "/home/*/.cache"
      ".git"
    ];

    inherit pruneOpts;
    inherit checkOpts;
    timerConfig = {
      OnCalendar = "00:05";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };

    backupPrepareCommand =
      ''
        ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"
      ''
      + lib.optionalString config.services.paperless.enable ''
        mkdir -p /var/lib/paperless/backups
        ${config.services.paperless.dataDir}/paperless-manage document_exporter /var/lib/paperless/backups -d -f -p
      '';
  };

  systemd.services."restic-backups-system-backup" = {
    onSuccess = [ "restic-notify-system-backup@success.service" ];
    onFailure = [ "restic-notify-system-backup@failure.service" ];
  };

  systemd.services."restic-notify-system-backup@" = {
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.age.secrets.restic-systembackup-env.path; # contains heathchecks.io UUID
      ExecStart = "${pkgs.healthchecks-ping}/bin/healthchecks-ping $HC_UUID $MONITOR_EXIT_STATUS $MONITOR_UNIT";
    };
  };
}
