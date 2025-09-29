{ config, ... }:
{
  age.secrets = {
    healthchecks-restic-systembackup = {
      file = ../secrets/healthchecks/restic-systembackup.env.age;
    };
    healthchecks-restic-b2 = {
      file = ../secrets/healthchecks/restic-b2.env.age;
    };
    healthchecks-rclone-sync-b2 = {
      file = ../secrets/healthchecks/rclone-sync-b2.env.age;
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
