{ config, ... }:
{
  services.healthchecks-ping = {
    restic-backups-system-backup = {
      urlFile = config.age.secrets.restic-systembackup-env.path;
    };
    restic-backups-b2 = {
      urlFile = config.age.secrets.resticb2env.path;
    };
    rclone-sync-b2 = {
      urlFile = config.age.secrets.rclone-sync.path;
    };
  };
}
