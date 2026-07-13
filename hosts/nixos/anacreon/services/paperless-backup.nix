{ config, ... }:
{
  services.restic.backups.paperless = {
    initialize = true;
    repositoryFile = config.age.secrets."restic/paperless-repository".path;
    passwordFile = config.age.secrets."restic/paperless-password".path;
    environmentFile = config.age.secrets."restic/paperless.env".path;

    paths = [ "/var/lib/paperless/export" ];

    extraBackupArgs = [
      "--cleanup-cache"
      "--tag paperless"
      "--tag export"
    ];

    # Backrest is the sole owner of forget/prune and retention policy for this
    # repository. This unit only creates snapshots.
    timerConfig = null;
  };

  # Start the backup only after Paperless has produced a complete export.
  systemd.services.paperless-exporter.onSuccess = [ "restic-backups-paperless.service" ];
  systemd.services.restic-backups-paperless.after = [ "paperless-exporter.service" ];
}
