{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.netdata = {
    enable = true;
    configDir = {
      "go.d/httpcheck.conf" = pkgs.writeText "httpcheck.conf" ''
          update_every        : 60
          autodetection_retry : 0
          priority            : 70000

          jobs:
            - name: sabnzbd
              url: https://sabnzbd.${fqdn}
            - name: plex
              url: https://plex.${fqdn}
            - name: radarr
              url: https://radarr.${fqdn}
            - name: sonarr
              url: https://sonarr.${fqdn}
            - name: prowlarr
              url: https://prowlarr.${fqdn}

            - name: unifi
              url: https://192.168.1.237:8443
              tls_skip_verify: yes
            - name: proxmox
              url: https://192.168.1.7:8006
              tls_skip_verify: yes

            - name: restic
              url: https://restic.${fqdn}
      '';
    };
  };
}
