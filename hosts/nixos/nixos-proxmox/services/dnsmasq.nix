{
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.dnsmasq = {
    enable = true;
  };
  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
