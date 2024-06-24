{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.networking) domain;
  host_whitelist = "${config.networking.hostName},sabnzbd.${domain}"; # comma-separated
in
{
  services.sabnzbd = {
    enable = true;
    group = "media";
    package = pkgs.unstable.sabnzbd;
  };

  services.caddy.virtualHosts."sabnzbd.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8080
    '';
    useACMEHost = domain;
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
