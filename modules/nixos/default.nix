{
  my-config = import ../common/myconfig.nix;
  rclone-sync = import ./rclone-sync.nix;

  # restic = import ./restic.nix;
  healthchecks = import ./healthchecks.nix;
}
