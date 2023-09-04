{
  pkgs,
  config,
  ...
}: let
  fqdn = config.networking.fqdn;
in {
  services.caddy = {
    enable = true;
    globalConfig = ''
      servers {
        metrics
      }
    '';
    # service-specific config for Caddy reverse-proxying located
    # in each service file (ie sabnzbd.nix, etc.)
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
