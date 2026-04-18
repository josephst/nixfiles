{
  config,
  lib,
  ...
}:
let
  siteHost = "backrest.${config.hostSpec.tailnet}";
  tailscaleServe = lib.getExe config.services.tailscale.package;
in
{
  services = {
    backrest = {
      enable = true;
      bindAddress = "127.0.0.1";
    };
    caddy.virtualHosts."${siteHost}" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:9898
      '';
    };
  };

  systemd.services.anacreon-backrest-tailscale-serve = {
    description = "Tailscale Serve proxy for Anacreon Backrest";
    after = [
      "backrest.service"
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
        "--service=srv:backrest"
        "--https=443"
        "http://127.0.0.1:9898"
      ];
      ExecStop = "${tailscaleServe} serve clear srv:backrest";
    };
  };
}
