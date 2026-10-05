#!/usr/bin/env bash
set -euo pipefail

month=$(date +%Y-%m)

run_monthly() {
  local stamp="$STATE_DIRECTORY/$1-month"
  if [[ ! -f "$stamp" ]] || [[ "$(cat "$stamp")" != "$month" ]]; then
    systemctl start "$2"
    # Only a successful service run advances the monthly maintenance stamp.
    printf '%s\n' "$month" > "$stamp"
  fi
}

cleanup_snapshot() {
  if [[ -d "$RESTIC_COPY" ]]; then
    btrfs subvolume delete "$RESTIC_COPY"
  fi
}

# A oneshot service's start job waits for all of its commands to finish, and
# propagates failure. Stop the pipeline if any stage fails.
systemctl start restic-backups-system-backup.service
run_monthly local restic-backups-local-maintenance.service

# Delete any snapshot left by a power loss, then upload a stable view of the
# repository. Local pruning finishes before this snapshot is taken.
cleanup_snapshot
trap cleanup_snapshot EXIT
btrfs subvolume snapshot -r "$RESTIC_SOURCE" "$RESTIC_COPY"
systemctl start rclone-sync-b2.service
cleanup_snapshot

run_monthly b2 restic-backups-b2.service
