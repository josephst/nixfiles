{ config, lib, ... }:
{
  networking.domain = "homelab.josephstahl.com";
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;

    networks = {
      "10-lan" = {
        matchConfig.Name = "enp5s0";
        DHCP = "yes";
        networkConfig = {
          DNS = [
            "1.1.1.1"
            "8.8.8.8"
          ];
          MulticastDNS = true;
          IPv6AcceptRA = true;
        };
        # domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        linkConfig = {
          RequiredForOnline = "routable";
          Multicast = true;
        };
      };
    };
  };
  networking.firewall.allowedUDPPorts =
    lib.optional config.systemd.network.networks."10-lan".networkConfig.MulticastDNS
      5353;
}
