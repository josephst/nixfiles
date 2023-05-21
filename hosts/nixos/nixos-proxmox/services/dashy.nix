{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  format = pkgs.formats.yaml {};
  dashyConfig = {
    pageInfo = {
      title = "Dashy (STATIC - Caddy)";
      navLinks = [
        {
          title = "GitHub";
          path = "https://github.com/josephst";
        }
      ];
    };
    appConfig = {
      theme = "colorful";
      statusCheck = false;
    };
    sections = [
      {
        name = "Media";
        items = [
          {
            title = "Plex";
            url = "http://plex.${fqdn}";
            icon = "hl-plex";
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
            title = "Unifi (on Proxmox)";
            url = "https://proxmox-unifi.taildbd4c.ts.net:8443";
            icon = "hl-unifi";
          }
          {
            title = "Uptime Kuma";
            url = "https://uptime.${fqdn}";
            icon = "hl-uptime-kuma";
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
          }
          {
            title = "Proxmox";
            url = "https://proxmox.taildbd4c.ts.net:8006";
            icon = "hl-proxmox";
          }
        ];
      }
    ];
  };
  configFile = format.generate "conf.yml" dashyConfig;
  dashy = pkgs.dashy.overrideAttrs (finalAttrs: previousAttrs: {
    inherit configFile;
  });
in {
  services.caddy.virtualHosts."dashy.${fqdn}" = {
    extraConfig = ''
      encode gzip
      file_server
      root * ${dashy}
    '';
    useACMEHost = fqdn;
  };
}
