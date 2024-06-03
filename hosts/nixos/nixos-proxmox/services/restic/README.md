# Restic Backups

- `b2-copy`: copies backups from this system to a remote B2 repository (using Rclone).
The corresponding module is `rclone-to-b2.nix`
- `b2-check`: checks backups (ie `restic check`) stored on B2
- `local-storage`: **checks** (does NOT back up) the HDDs which are storing
restic backups from other devices on the LAN
- `rcloneRemoteDir`: Agenix-related config
- `restic-user`: creates a user for Restic backups so that they are not run as root