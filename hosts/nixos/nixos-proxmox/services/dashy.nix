{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.dashy = {
    enable = true;
    imageTag = "2.1.1";
    port = 4000;
    extraOptions = [];
    settings = {
      pageInfo = {
        title = "Dashy";
        navLinks = [
          {
            title = "GitHub";
            path = "https://github.com/josephst";
          }
        ];
      };
      appConfig = {
        theme = "colorful";
        statusCheck = true;
      };
      sections = [
        {
          name = "Media";
          items = [
            {
              title = "Plex";
              url = "http://plex.${fqdn}";
              icon = "hl-plex";
              statusCheck = false; # not working for plex
            }
            {
              title = "Sabznzbd";
              url = "http://sabnzbd.${fqdn}";
              icon = "hl-sabnzbd";
            }
            {
              title = "Radarr";
              url = "http://radarr.${fqdn}";
              icon = "hl-radarr";
            }
            {
              title = "Sonarr";
              url = "http://sonarr.${fqdn}";
              icon = "hl-sonarr";
            }
            {
              title = "Prowlarr";
              url = "http://prowlarr.${fqdn}";
              icon = "hl-prowlarr";
            }
          ];
        }
        {
          name = "Networking";
          items = [
            {
              title = "Pi-Hole (on Proxmox)";
              url = "http://pihole.proxmox.${domain}/admin/login.php";
              icon = "hl-pihole";
            }
            {
              title = "Unifi (on Proxmox)";
              url = "https://proxmox-unifi.taildbd4c.ts.net:8443";
              statusCheckAllowInsecure = true;
              icon = "hl-unifi";
            }
          ];
        }
        {
          name = "Storage and Backup";
          items = [
            {
              title = "Synology DSM";
              url = "https://nas.${domain}:5001";
              icon = "hl-synology";
              statusCheckAllowInsecure = true;
            }
            {
              title = "Proxmox";
              url = "https://proxmox.taildbd4c.ts.net:8006";
              icon = "hl-proxmox";
              statusCheckAllowInsecure = true;
            }
          ];
        }
      ];
    };
  };

  services.caddy.virtualHosts."dashy.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:4000
    '';
    useACMEHost = fqdn;
  };
}
