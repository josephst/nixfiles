{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  age.secrets.paperless-admin.file = ../secrets/paperless-admin.age;

  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless-admin.path;
    settings = {
      PAPERLESS_URL = "https://paperless.${domain}";
      PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ created }} {{ title }}";
    };
    exporter.enable = true; # defaults to running at 1:30 AM
  };

  services.caddy.virtualHosts."paperless.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.paperless.port}
    '';
    useACMEHost = domain;
  };

  services.restic.backups.system-backup.paths = [
    "/var/lib/paperless/"
  ];
}
