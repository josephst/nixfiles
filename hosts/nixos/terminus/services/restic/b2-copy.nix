{ config, ... }:
let
  localPath = "/storage/restic";
in
{
  imports = [
    ./rcloneRemoteDir.nix # sets config.age.secrets.rcloneRemoteDir.path
  ];

  # age.secrets.rcloneConf # defined elsewhere

  services.restic.clone = {
    enable = true;
    dataDir = localPath;
    environmentFile = config.age.secrets.rcloneRemoteDir.path;
    rcloneConfFile = config.age.secrets.rcloneConf.path;
    extraRcloneArgs = [
      "--transfers=16"
      "--b2-hard-delete"
      "-v"
    ];
    pingHealthchecks = true;

    timerConfig = {
      OnCalendar = "06:00";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };
}
