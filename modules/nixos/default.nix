{
  myConfig = import ../common/myConfig;
  hostSpec = import ../common/host-spec.nix;

  rcloneSync = import ./rclone-sync.nix;
  healthchecks = import ./healthchecks.nix;
}
