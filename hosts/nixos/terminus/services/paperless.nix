{ config, ... }:
let
  inherit (config.networking) fqdn;
in
{
  age.secrets.paperless-admin.file = ../secrets/paperless-admin.age;

  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless-admin.path;
    settings = {
      PAPERLESS_FILENAME_FORMAT = "{created_year}/{correspondent}/{created} {title}";
    };
  };

  services.caddy.virtualHosts."paperless.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.paperless.port}
    '';
    useACMEHost = fqdn;
  };

  # Rclone: Sync OneDrive folder to consumption folder
}
