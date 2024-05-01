{
  pkgs,
  config,
  lib,
  ...
}:
let
  fqdn = config.networking.fqdn;
  host_whitelist = "${config.networking.hostName},sabnzbd.${fqdn}"; # comma-separated
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

  system.activationScripts.sabnzbd = {
    # may need to restart sabnzbd (systemctl restart sabnzbd) after this
    text = ''
      if [[ -e ${config.services.sabnzbd.configFile} ]]; then
        # file exists, modify it
        ${lib.getBin pkgs.gnused}/bin/sed -i 's/host_whitelist = .*/host_whitelist = ${host_whitelist}/g' ${config.services.sabnzbd.configFile}
      else
        # create new file
        echo "host_whitelist = ${host_whitelist}" > ${config.services.sabnzbd.configFile}
        chown ${config.services.sabnzbd.user}:${config.services.sabnzbd.group} ${config.services.sabnzbd.configFile}
      fi
    '';
  };
}
