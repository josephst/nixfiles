# Restic Backups

- `copy-to-s3`: copies backups from local Restic repository (located at `/storage/restic`) to S3
  daily, and performs remote retention/pruning plus a sampled check monthly
- `restic-user`: creates a `restic` user on this system to run backups as
- `system-backup`: copies files to the local Restic repository (located at `/storage/restic`) daily;
  repository-wide retention/pruning and checks run separately each month for all devices that back up here
