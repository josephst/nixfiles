# Restic Backups

- `copy-to-s3`: copies backups from local Restic repository (located at `/storage/restic`) to S3
  - it will also read a small sample of these backups to check the remote repository
- `restic-user`: creates a `restic` user on this system to run backups as
- `system-backup`: copies files to the local Restic repository (located at `/storage/restic`) and
  performs maintenance on the repository (prune/ check for all devices which back up here)