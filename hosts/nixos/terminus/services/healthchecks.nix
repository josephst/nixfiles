{ config, ... }:
{
  age.secrets = {
    healthchecks-restic-systembackup = {
      file = ../secrets/restic/systembackup.env.age;
    };
    healthchecks-restic-b2 = {
      file = ../secrets/restic/b2.env.age;
    };
    healthchecks-rclone-sync-b2 = {
      file = ../secrets/restic/rclone-sync.env.age;
    };
  };

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
