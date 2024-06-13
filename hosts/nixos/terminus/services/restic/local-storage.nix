{ config, pkgs, ... }:
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
# healthcheckFinishScript = ''
#   # args: $1 is UUID, #2 is exit status (non-zero in case of failures)
#   output = $(systemctl status $1 -l -n 1000 | ${pkgs.coreutils}/bin/tail --bytes 100000)
#   ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/$1/$2" --data-raw $output
# '';
{

  # maintenance of the local restic repo(s) at /storage/restic
  services.restic.backups.localstorage = {
    initialize = false;
    user = "restic";
    passwordFile = config.age.secrets.restic-localstorage-pass.path;
    environmentFile = config.age.secrets.restic-localstorage-env.path; # contains heathchecks.io UUID
    repository = "/storage/restic";
    paths = [ ]; # no paths to backup, only check/prune the existing repo
    inherit pruneOpts;
    inherit checkOpts;
    timerConfig = {
      OnCalendar = "*-*-* 6:00:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    backupPrepareCommand = ''
      # preStart
      ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"

      # remove old locks
      ${pkgs.restic}/bin/restic unlock
    '';
  };

  systemd.services."restic-backups-localstorage" = {
    onSuccess = [ "restic-notify-localstorage@success.service" ];
    onFailure = [ "restic-notify-localstorage@failure.service" ];
  };

  systemd.services."restic-notify-localstorage@" = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.restic-localstorage-env.path; # contains heathchecks.io UUID
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