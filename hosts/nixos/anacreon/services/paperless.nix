{
  config,
  ...
}:
let
  siteHost = "paperless.${config.hostSpec.tailnet}";
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
}
