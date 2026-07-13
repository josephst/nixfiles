{
  config,
  lib,
  ...
}:
let
  tailscaleServe = lib.getExe config.services.tailscale.package;
in
{
  services = {
    copyparty = {
      enable = true;
      settings = {
        ansi = true;
        i = "127.0.0.1";
        # Tailscale Serve strips client-supplied identity headers before
        # injecting the authenticated tailnet user's login.
        idp-h-usr = "Tailscale-User-Login";
        no-reload = true;
        xff-src = "127.0.0.1";
      };
      volumes = {
        "/" = {
          path = "/var/lib/copyparty/share";
          access = {
            r = "*";
            rwmd = "@acct";
          };
        };
      };
    };
  };

  systemd.services.anacreon-copyparty-tailscale-serve = {
    description = "Tailscale Serve proxy for Anacreon Copyparty";
    after = [
      "copyparty.service"
      "tailscaled.service"
      "tailscaled-autoconnect.service"
      "tailscaled-set.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.concatStringsSep " " [
        tailscaleServe
        "serve"
        "--service=svc:copyparty"
        "--https=443"
        "http://127.0.0.1:3923"
      ];
      ExecStop = "${tailscaleServe} serve clear svc:copyparty";
    };
  };
}
