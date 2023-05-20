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
      title = "Dashy STATIC (Caddy)";
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
  configFile = format.generate "conf.yml" dashyConfig;
  dashy = pkgs.dashy.overrideAttrs (finalAttrs: previousAttrs: {
    inherit configFile;
  });
in {
  # services.dashy = {
  #   enable = true;
  #   package = dashy;
  # };

  services.caddy.virtualHosts."dashy.${fqdn}" = {
    # extraConfig = ''
    #   reverse_proxy http://localhost:4000
    # '';
    extraConfig = ''
      encode gzip
      file_server
      root * ${dashy}
    '';
    useACMEHost = fqdn;
  };
}
