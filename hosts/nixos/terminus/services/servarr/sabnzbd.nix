{
  config,
  ...
}:
let
  inherit (config.networking) domain;
  # host_whitelist = "${config.networking.hostName},sabnzbd.${domain}"; # comma-separated
  starting_config = ''
    __version__ = 19
    __encoding__ = utf-8
    [misc]
    port = 8082
    host_whitelist = "${config.networking.hostName},sabnzbd.${domain}"
  '';
in
{
  services.sabnzbd = {
    enable = true;
    group = "media";
  };

  services.caddy.virtualHosts."sabnzbd.${domain}" = {
    # remember to edit sabnzbd config to listen on 8082 (otherwise it won't start)
    extraConfig = ''
      reverse_proxy localhost:8082
    '';
    useACMEHost = domain;
  };

  # hardening options copied from upstream
  # https://github.com/sabnzbd/sabnzbd/blob/master/linux/sabnzbd%40.service
  systemd.services.sabnzbd.serviceConfig = {
    ProtectSystem = "full";
    DeviceAllow = [
      "/dev/null rw"
      "/dev/urandom r"
    ];
    DevicePolicy = "strict";
    NoNewPrivileges = true;
  };

  systemd.tmpfiles.settings = {
    "10-sabnzbd" = {
      "/var/lib/sabnzbd/sabnzbd.ini" = {
        f = {
          user = "sabnzbd";
          group = "media";
          mode = "0600";
          argument = starting_config;
        };
      };
    };
  };

  # system.activationScripts.sabnzbd = {
  #   # may need to restart sabnzbd (systemctl restart sabnzbd) after this
  #   text = ''
  #     if [[ -e ${config.services.sabnzbd.configFile} ]]; then
  #       # file exists, modify it
  #       ${lib.getBin pkgs.gnused}/bin/sed -i 's/host_whitelist = .*/host_whitelist = ${host_whitelist}/g' ${config.services.sabnzbd.configFile}
  #     else
  #       # create new file
  #       mkdir -p $(dirname ${config.services.sabnzbd.configFile})
  #       echo "host_whitelist = ${host_whitelist}" > ${config.services.sabnzbd.configFile}
  #       chown ${config.services.sabnzbd.user}:${config.services.sabnzbd.group} ${config.services.sabnzbd.configFile}
  #     fi
  #   '';
  # };
}
