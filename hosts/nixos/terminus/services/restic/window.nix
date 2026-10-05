{ config, pkgs, ... }:
let
  window = pkgs.writeShellApplication {
    name = "restic-backup-window";
    runtimeInputs = [
      config.systemd.package
      pkgs.btrfs-progs
      pkgs.coreutils
    ];
    text = builtins.readFile ./window.sh;
  };
in
{
  systemd.tmpfiles.rules = [ "d /storage/.restic-copy 0700 root root -" ];

  systemd.services.restic-backup-window = {
    description = "Serialized local and cloud backup window";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [ "/storage/restic" ];
    environment = {
      RESTIC_COPY = config.services.rclone-sync.b2.dataDir;
      RESTIC_SOURCE = "/storage/restic";
    };
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "infinity";
      StateDirectory = "restic-backup-window";
      StateDirectoryMode = "0700";
      ExecStart = ''
        ${config.systemd.package}/bin/systemd-inhibit --mode=block --what=idle:sleep --who=restic-backup-window --why="Server backup and maintenance window" ${window}/bin/restic-backup-window
      '';
    };
  };

  systemd.timers.restic-backup-window = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      AccuracySec = "1s";
      OnCalendar = "06:00";
      Persistent = true;
      RandomizedDelaySec = "10m";
      WakeSystem = true;
    };
  };
}
