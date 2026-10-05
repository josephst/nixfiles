# Restic Backups

- `copy-to-s3`: copies backups from local Restic repository (located at `/storage/restic`) to S3
  daily, and performs remote retention/pruning plus a sampled check monthly
- `system-backup`: copies files to the local Restic repository (located at `/storage/restic`) daily;
  repository-wide retention/pruning and checks run monthly for all devices that back up here
- `window`: schedules and serializes the server backup jobs

`restic-backup-window.timer` wakes Terminus daily at 06:00, with a random delay of
up to 10 minutes. It catches up after downtime. Individual backup and maintenance
timers are disabled; the window runs and waits for each stage in this order:

1. Terminus system backup.
2. Local repository retention/pruning and check, when due for the current month.
3. Create a temporary read-only Btrfs snapshot and copy it to B2 with Rclone.
4. Remove the temporary snapshot.
5. B2 retention/pruning and check, when due for the current month.

The upload reads `/storage/.restic-copy/repository`, preserving a stable source
while the live repository receives backups. Client locks and in-progress upload
temporary files are excluded from the copy. The snapshot is removed on success or failure; leftovers after power loss
are removed at the next upload. Snapshot storage remains allocated until cleanup.

Monthly success stamps live in `/var/lib/restic-backup-window`. Each maintenance
stage runs at the first window of a new month, including after missed schedules;
on first installation both are due. A failed stage stops the window and is retried
at the next daily run without advancing its stamp. Existing per-stage Healthchecks
reporting is preserved.

Run the complete window manually with:

```sh
sudo systemctl start restic-backup-window.service
```

Start uploads through the window so their source snapshot exists. Avoid running
individual maintenance jobs concurrently with the window.

The entire window holds an `idle:sleep` inhibitor, including between stages.
The Restic backup and maintenance commands, including unlock, forget/prune,
and check, block sleep with `systemd-inhibit`. The Rclone B2 upload also blocks sleep
until it finishes. Locks are released when the commands exit, including on failure.
Inspect active locks with `systemd-inhibit --list`.

For ad hoc commands (including the generated `restic-system-backup`,
`restic-local-maintenance`, and `restic-b2` wrappers), use:

```sh
sudo systemd-inhibit --mode=block --what=sleep --why="Manual Restic maintenance" \
  restic-local-maintenance check
```

This does not keep Terminus awake for laptop uploads or Backrest operations;
those still need activity detection or a server-side keep-awake lease.

Terminus allows manual suspend (`systemctl suspend`). Automatic idle suspend is
not enabled. RTC wake and Wake-on-LAN still need hardware/firmware validation.
