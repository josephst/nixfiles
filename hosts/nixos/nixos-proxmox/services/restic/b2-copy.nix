{ config, pkgs, ... }:
let
  localPath = "/storage/restic";
in
{
  age.secrets.rcloneRemoteDir = {
    file = ../../../../../secrets/rcloneRemote.age;
    owner = "restic";
  };
  # age.secrets.rcloneConf # defined elsewhere

  services.restic.clone = {
    enable = true;
    dataDir = localPath;
    remoteDirFile = config.age.secrets.rcloneRemoteDir.path;
    rcloneConfFile = config.age.secrets.rcloneConf.path;
    extraRcloneArgs = [ "--transfers=16" "--b2-hard-delete --dry-run" ];
  };
}
