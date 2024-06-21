{ config, pkgs, ... }:
let
  port = toString 8081;
  inherit (config.networking) fqdn;
in
{
  services.restic.server = {
    enable = true;
    dataDir = "/storage/restic";
    listenAddress = port;
    extraFlags = [ "--no-auth" ]; # auth managed by tailscale
  };

  services.caddy.virtualHosts."restic.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${port}
    '';
    useACMEHost = fqdn;
  };

  services.restic.backups.local-maintenance =
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
      # perform maintenance (prune, check) on the repos that restic-rest-server manages
      initialize = false;
      passwordFile = config.age.secrets.restic-localstorage-pass.path; # Repository password
      environmentFile = config.age.secrets.restic-localmaintenance-env.path; # HC_UUID
      repository = config.services.restic.server.dataDir;

      paths = [ ]; # check and prune only

      inherit pruneOpts;
      inherit checkOpts;

      timerConfig = {
        OnCalendar = "23:00";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };

      backupPrepareCommand = ''
        ${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/start"
      '';
    };
  systemd.services."restic-backups-local-maintenance" = {
    onSuccess = [ "restic-notify-local-maintenancep@success.service" ];
    onFailure = [ "restic-notify-local-maintenancep@failure.service" ];
  };

  systemd.services."restic-notify-local-maintenancep@" = {
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.age.secrets.restic-localmaintenance-env.path; # contains heathchecks.io UUID
      ExecStart = "${pkgs.healthchecks-ping}/bin/healthchecks-ping $HC_UUID $MONITOR_EXIT_STATUS $MONITOR_UNIT";
    };
  };
}
