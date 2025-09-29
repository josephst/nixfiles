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
      urlFile = config.age.secrets.healthchecks-restic-systembackup.path;
    };
    restic-backups-b2 = {
      urlFile = config.age.secrets.healthchecks-restic-b2.path;
    };
    rclone-sync-b2 = {
      urlFile = config.age.secrets.healthchecks-rclone-sync-b2.path;
    };
  };
}
