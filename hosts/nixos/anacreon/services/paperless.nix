{
  config,
  lib,
  ...
}:
let
  siteHost = "paperless.${config.hostSpec.tailnet}";
  tailscaleServe = lib.getExe config.services.tailscale.package;
in
{
  age.secrets.paperless-admin.file = ../secrets/paperless-admin.age;

  services = {
    paperless = {
      enable = true;
      passwordFile = config.age.secrets.paperless-admin.path;
      settings = {
        PAPERLESS_URL = "https://${siteHost}";
        PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ created }} {{ title }}";
      };
      exporter.enable = true;
    };
    caddy.virtualHosts."${siteHost}" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.paperless.port}
      '';
    };
  };

  systemd.services.anacreon-paperless-tailscale-serve = {
    description = "Tailscale Serve proxy for Anacreon Paperless";
    after = [
      "paperless.service"
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
        "--service=svc:paperless"
        "--https=443"
        "http://127.0.0.1:${toString config.services.paperless.port}"
      ];
      ExecStop = "${tailscaleServe} serve clear svc:paperless";
    };
  };
}
