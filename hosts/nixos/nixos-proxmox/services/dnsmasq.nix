{
  pkgs,
  config,
  ...
}: let
  fqdn = config.networking.fqdn;
in {
  services.dnsmasq = {
    enable = true;
  };
  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
