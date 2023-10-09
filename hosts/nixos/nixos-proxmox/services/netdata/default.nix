{
  lib,
  config,
  pkgs,
  ...
}: let
  fqdn = config.networking.fqdn;
in {
  services.netdata = {
    enable = true;
    claimTokenFile = config.age.secrets.netdata_nixos_claim.path;
    # uptime monitoring now done up uptime-kuma
    # configDir = {
    #   "go.d/httpcheck.conf" = pkgs.writeText "httpcheck.conf" ''
    #     update_every        : 30
    #     autodetection_retry : 0
    #     priority            : 70000

    #     jobs:
    #       - name: sabnzbd
    #         url: https://sabnzbd.${fqdn}
    #       - name: plex
    #         url: https://plex.${fqdn}/web/index.html#!/
    #       - name: radarr
    #         url: https://radarr.${fqdn}
    #       - name: sonarr
    #         url: https://sonarr.${fqdn}
    #       - name: prowlarr
    #         url: https://prowlarr.${fqdn}

    #       - name: unifi
    #         url: https://192.168.1.237:8443
    #         tls_skip_verify: yes
    #       - name: proxmox
    #         url: https://192.168.1.7:8006
    #         tls_skip_verify: yes
    #   '';
    # };
  };
}
