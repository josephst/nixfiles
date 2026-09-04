{
  config,
  ...
}:
# ROLE: back up this machine to local storage (/storage). Repository-wide
# maintenance is kept separate so it also covers snapshots created by clients.
let
  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  maintenanceCheckOpts = [
    "--read-data-subset 5G"
    "--with-cache"
  ];
in
{
  age.secrets.restic-systembackup-env.file = ../../secrets/restic/systembackup.env.age;

  # backup to local repo (on HDD array), which is later copied to B2
  services.restic.backups.system-backup = {
    initialize = false;
    environmentFile = config.age.secrets.restic-systembackup-env.path; # RESTIC_PASSWORD
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

    timerConfig = {
      OnCalendar = "12:05";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Apply retention and integrity checks to every snapshot group in the local
  # repository, including snapshots written by client machines.
  services.restic.backups.local-maintenance = {
    initialize = false;
    environmentFile = config.age.secrets.restic-systembackup-env.path;
    repository = "rest:http://${config.services.restic.server.listenAddress}";

    inherit pruneOpts;
    checkOpts = maintenanceCheckOpts;

    timerConfig = {
      OnCalendar = "*-*-01 02:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  systemd.services = {
    restic-backups-system-backup = {
      requires = [ "restic-rest-server.socket" ];
      after = [ "restic-rest-server.socket" ];
    };
    restic-backups-local-maintenance = {
      requires = [ "restic-rest-server.socket" ];
      after = [ "restic-rest-server.socket" ];
    };
  };
}
