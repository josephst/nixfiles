{ config, ... }:
{
  age.secrets.paperless-admin.file = ../../terminus/secrets/paperless-admin.age;

  services = {
    paperless = {
      enable = true;
      passwordFile = config.age.secrets.paperless-admin.path;
      settings = {
        PAPERLESS_URL = "https://anacreon-paperless";
        PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ created }} {{ title }}";
      };
      exporter.enable = true;
    };

    tailscale.serve.services.anacreon-paperless = {
      endpoints = {
        "tcp:443" = "http://127.0.0.1:${toString config.services.paperless.port}";
      };
    };
  };
}
