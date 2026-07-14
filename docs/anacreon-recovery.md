# Anacreon backup and recovery

Paperless exports and Backrest state are stored as separate snapshots in one
Restic repository. The Paperless exporter is the only timer: a successful
export starts the Paperless snapshot, whose success then starts the Backrest
state snapshot. Backrest remains the sole owner of retention and pruning.

## Verify the backup chain

Start an export manually and wait for the three one-shot units to finish:

```bash
sudo systemctl start paperless-exporter.service
sudo journalctl -u paperless-exporter.service \
  -u restic-backups-paperless.service \
  -u restic-backups-backrest.service --since today

sudo restic-paperless snapshots --tag paperless --tag export
sudo restic-backrest snapshots --tag backrest
```

The exporter temporarily stops the Paperless application units and starts them
again afterwards. Verify that the web UI and document consumer return before
considering the run successful.

## Stage a restore without changing live data

The generated `restic-paperless` and `restic-backrest` wrappers load the
repository, password, and object-store environment from Agenix. Run them as
root because the snapshot paths and secret files are not user-readable.

```bash
stamp="$(date +%Y%m%d-%H%M%S)"
target="/var/lib/backrest/restores/$stamp"
sudo install -d -o backrest -g backrest -m 0700 "$target"

sudo restic-paperless restore latest \
  --tag paperless --tag export --target "$target/paperless"
sudo restic-backrest restore latest \
  --tag backrest --target "$target/backrest"
```

Restic preserves absolute source paths below the target. The expected staged
directories are therefore:

- `$target/paperless/var/lib/paperless/export`
- `$target/backrest/var/lib/backrest`

Check that the Paperless export contains `manifest.json`, and inspect ownership
and representative files without copying either restore over live state.

## Restore Backrest after a disaster

Stop Backrest, stage the `backrest`-tagged snapshot as above, and inspect it
before replacing `/var/lib/backrest`. Preserve mode `0700` and restore ownership
to `backrest:backrest` before starting `backrest.service`. Confirm the UI login,
repository connection, snapshot history, and one harmless staged restore.

Do not restore a snapshot into the live directory while Backrest is running.

## Restore Paperless into a fresh instance

Paperless requires the importer to target a completely empty installation. Use
the exact Paperless version that created the export; the current configured
version can be checked with:

```bash
paperless-manage --version
```

On a disposable or newly rebuilt empty instance, copy the staged export to a
directory readable by the `paperless` user and run:

```bash
sudo paperless-manage document_importer /path/to/restored/export --no-progress-bar
sudo paperless-manage document_sanity_checker
```

Do not run `document_importer` against the existing production database or data
directories. After import, recreate API tokens, verify document/tag/
correspondent counts, open representative originals and archived documents,
and test search and consumption before declaring the recovery successful.
