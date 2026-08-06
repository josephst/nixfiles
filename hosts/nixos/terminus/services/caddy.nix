{
  services.caddy = {
    enable = true;
    openFirewall = true;
    # service-specific config for Caddy reverse-proxying located
    # in each service file (ie sabnzbd.nix, etc.)
  };
}
