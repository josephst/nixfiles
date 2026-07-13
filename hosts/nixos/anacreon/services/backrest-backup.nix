{ config, ... }:
{
  services.restic.backups.backrest = {
    initialize = true;
    repositoryFile = config.age.secrets."restic/paperless-repository".path;
    passwordFile = config.age.secrets."restic/paperless-password".path;
    environmentFile = config.age.secrets."restic/paperless.env".path;

    # Preserve Backrest's configuration, authentication state, and operation
    # history. Restores are staged below this directory before being applied.
    paths = [ "/var/lib/backrest" ];

    extraBackupArgs = [
      "--cleanup-cache"
      "--tag backrest"
    ];

    # Backrest owns forget/prune and retention policy for this repository.
    timerConfig = null;
  };

  # Serialize snapshots in the shared repository. The existing Paperless
  # exporter schedule remains the single trigger for both recovery snapshots.
  systemd.services.restic-backups-paperless.onSuccess = [
    "restic-backups-backrest.service"
  ];
  systemd.services.restic-backups-backrest.after = [
    "restic-backups-paperless.service"
  ];
}
