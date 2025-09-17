{
  config,
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
  age.secrets.restic-localstorage-pass.file = ../../secrets/restic/localstorage.pass.age;
  age.secrets.restic-systembackup-env.file = ../../secrets/restic/systembackup.env.age;

  # backup to local repo (on HDD array), which is later copied to B2
  services.restic.backups.system-backup = {
    initialize = false;
    passwordFile = config.age.secrets.restic-localstorage-pass.path; # Repository password
    environmentFile = config.age.secrets.restic-systembackup-env.path; # HC_UUID
    repository = "rest:http://${config.services.restic.server.listenAddress}";

    paths = [
      "/home"
    ];
    exclude = [
      "/home/*/.cache"
      ".git"
      "*.gguf" # exclude models
    ];

    extraBackupArgs = [ "--cleanup-cache" ];

    inherit pruneOpts;
    inherit checkOpts;
    timerConfig = {
      OnCalendar = "00:05";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  services.healthchecks-ping.system-backup = {
    urlFile = config.age.secrets.restic-systembackup-env.path;
    unitName = "restic-backups-system-backup";
  };
}
