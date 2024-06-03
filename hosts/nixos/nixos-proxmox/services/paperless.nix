{
  pkgs,
  config,
  lib,
  ...
}:
let
  fqdn = config.networking.fqdn;
in
{
  age.secrets.paperless-admin.file = ../secrets/paperless-admin.age;

  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless-admin.path;
  };

  services.caddy.virtualHosts."paperless.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.paperless.port}
    '';
    useACMEHost = fqdn;
  };

  # Rclone: Sync OneDrive folder to consumption folder
}
