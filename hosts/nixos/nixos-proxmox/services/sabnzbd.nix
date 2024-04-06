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
  services.sabnzbd = {
    enable = true;
    group = "media";
    package = pkgs.unstable.sabnzbd;
  };

  # TODO: find a way to add this domain to /var/lib/sabnzbd/sabnzbd.ini without
  # having to manually edit file
  services.caddy.virtualHosts."sabnzbd.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8080
    '';
    useACMEHost = fqdn;
  };
}
