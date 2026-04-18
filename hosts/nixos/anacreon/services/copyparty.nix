{
  config,
  lib,
  ...
}:
let
  siteHost = "copyparty.${config.hostSpec.tailnet}";
  tailscaleServe = lib.getExe config.services.tailscale.package;
in
{
  services = {
    copyparty = {
      enable = true;
      settings = {
        ansi = true;
        i = "127.0.0.1";
        no-reload = true;
      };
      volumes = {
        "/" = {
          path = "/var/lib/copyparty/share";
          access = {
            rwmd = "*";
          };
        };
      };
    };
    caddy.virtualHosts."${siteHost}" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:3923
      '';
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
        "--service=srv:copyparty"
        "--https=443"
        "http://127.0.0.1:3923"
      ];
      ExecStop = "${tailscaleServe} serve clear srv:copyparty";
    };
  };
}
