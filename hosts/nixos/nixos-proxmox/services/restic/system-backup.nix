{
  config,
  pkgs,
  lib,
  ...
}:
# ROLE: to back up this machine to B2 storage using Restic
# This way, services such as Paperless are also backed up
let
  pruneOpts = [
    "--keep-daily 30"
    "--keep-weekly 52"
    "--keep-monthly 24"
    "--keep-yearly 10"
    "--keep-tag forever"
  ];
  checkOpts = [
    "--read-data-subset 5G"
    "--with-cache"
  ];
in
{
  imports = [ ./rcloneRemoteDir.nix ];

  services.restic.backups.system-backup = {
    initialize = false;
    passwordFile = config.age.secrets.restic-localstorage-pass.path; # Repository password
    environmentFile = config.age.secrets.restic-systembackup-env.path; # HC_UUID
    repositoryFile = config.age.secrets.b2WithRclone.path; # Repository path
    rcloneConfigFile = config.age.secrets.rcloneConf.path; # RClone config

    paths = [
      # TODO: add to this as needed
      "/home"
      "/var/lib/paperless"
    ];
    exclude = [
      "/home/*/.cache"
      ".git"
    ];

    inherit pruneOpts;
    inherit checkOpts;
    timerConfig = {
      OnCalendar = "00:05";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };

    backupPrepareCommand = ''
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"
    '';
  };

  systemd.services."restic-backups-system-backup" = {
    onSuccess = [ "restic-notify-system-backup@success.service" ];
    onFailure = [ "restic-notify-system-backup@failure.service" ];
  };

  systemd.services."restic-notify-system-backup@" = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.restic-systembackup-env.path; # contains heathchecks.io UUID
      User = "restic"; # to read env file
      ExecStart = "${./healthcheck.sh} $HC_UUID $MONITOR_EXIT_STATUS $MONITOR_UNIT";
    };
    path = [
      pkgs.bash
      pkgs.curl
    ]; # coreutils, findutils, gnugrep, gnused, systemd already included
    # https://github.com/NixOS/nixpkgs/blob/31b67eb2d97c0671079458725700300c47d55c9e/nixos/lib/systemd-lib.nix#L440
  };
}