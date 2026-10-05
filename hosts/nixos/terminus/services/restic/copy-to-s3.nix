{ config, pkgs, ... }:
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
  age.secrets.resticb2env.file = ../../secrets/restic/b2.env.age;
  age.secrets.rcloneConf.file = ../../secrets/rclone.conf.age;
  age.secrets.rclone-sync.file = ../../secrets/restic/rclone-sync.env.age;

  # copy local Restic repo to S3-compatible repo
  services.rclone-sync.b2 = {
    enable = true;
    inhibitsSleep = true;
    # The backup window creates this read-only Btrfs snapshot before uploading.
    dataDir = "/storage/.restic-copy/repository";
    rcloneCommand = "copy";
    environmentFile = config.age.secrets.rclone-sync.path;
    rcloneConfFile = config.age.secrets.rcloneConf.path;
    extraRcloneArgs = [
      "--transfers=32"
      "--b2-hard-delete"
      "--fast-list"
      "--exclude=/locks/**" # Live clients' locks do not belong in the cloud repository.
      "--exclude=*.rest-server-temp*" # Incomplete uploads captured by the snapshot.
    ];

    timerConfig = null; # Started by restic-backup-window.
  };

  # Apply retention and integrity checks to the B2 repository once a month;
  # this does not create any snapshots.
  services.restic.backups.b2 = {
    inhibitsSleep = true;
    initialize = false;
    environmentFile = config.age.secrets.resticb2env.path;
    inherit pruneOpts;
    inherit checkOpts;

    backupPrepareCommand = ''
      # remove old locks
      ${config.systemd.package}/bin/systemd-inhibit \
        --mode=block --what=sleep --who=restic \
        --why="Prepare B2 repository maintenance" \
        ${pkgs.restic}/bin/restic unlock || true
    '';

    timerConfig = null; # Monthly maintenance is tracked by restic-backup-window.
  };
}
