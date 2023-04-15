{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
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

  systemd.services.sabnzbd = {
    after = ["network.target" "mnt-nas.automount"];
  };
}
