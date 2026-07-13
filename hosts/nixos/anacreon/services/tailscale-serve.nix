{
  config,
  lib,
  ...
}:
let
  tailscale = lib.getExe config.services.tailscale.package;
  routes = {
    backrest = {
      backend = "http://127.0.0.1:9898";
      after = [ "backrest.service" ];
    };
    copyparty = {
      backend = "http://127.0.0.1:3923";
      after = [ "copyparty.service" ];
    };
    home = {
      backend = "http://127.0.0.1:8080";
      after = [ "caddy.service" ];
    };
    paperless = {
      backend = "http://127.0.0.1:${toString config.services.paperless.port}";
      after = [ "paperless.service" ];
    };
  };
  tailscaleUnits = [
    "tailscaled.service"
    "tailscaled-autoconnect.service"
    "tailscaled-set.service"
  ];

  mkServeUnit =
    serviceName: route:
    lib.nameValuePair "anacreon-${serviceName}-tailscale-serve" {
      description = "Tailscale Serve proxy for Anacreon ${serviceName}";
      after = route.after ++ tailscaleUnits;
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];

      # Retry indefinitely if the daemon is running but tailnet authentication
      # has not completed when this unit first starts.
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5s";
        ExecStart = lib.escapeShellArgs [
          tailscale
          "serve"
          "--service=svc:${serviceName}"
          "--https=443"
          route.backend
        ];
        ExecStop = lib.escapeShellArgs [
          tailscale
          "serve"
          "clear"
          "svc:${serviceName}"
        ];
      };
    };
in
{
  # Keep using the CLI until tailscale/tailscale#18381 no longer causes HTTPS
  # services restored through `serve set-config` to come back as HTTP.
  systemd.services = lib.mapAttrs' mkServeUnit routes;
}
