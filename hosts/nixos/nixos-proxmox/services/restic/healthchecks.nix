{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  healthchecks = pkgs.writeShellApplication {
    name = "healthchecks-reporter";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      IFS=: read -r UUID ACTION INSTANCE <<< "$1"
      if [ "$ACTION" = "start" ]; then
          curl -m 10 --retry 5 "https://hc-ping.com/$UUID/start"
      else
          LOGS=$(journalctl --no-pager -n 50 -u "$INSTANCE")
          EXIT_CODE=$([[ "$ACTION" == "success" ]] && echo "0" || echo "1");
          curl -fSs -m 10 --retry 5 --data-raw "$LOGS" "https://hc-ping.com/$UUID/$EXIT_CODE"
      fi
    '';
  };
in {
  environment.systemPackages = [healthchecks];
  systemd.services."healthchecks@" = {
    description = "Report maintenance results to Healthchecks.io (%i)";
    after = ["syslog.target" "network.target"];
    serviceConfig = {
      # User = "restic";
      # Group = "restic";
      Type = "oneshot";
      ExecStart = "${healthchecks}/bin/healthchecks-reporter %i";
    };
  };
}
