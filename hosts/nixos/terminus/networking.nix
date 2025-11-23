{ lib, config, ... }:
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
          IPv6AcceptRA = true;
        };
        # domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        linkConfig = {
          RequiredForOnline = "routable";
        };
      };
    };
  };

  boot.kernel.sysctl = lib.mkIf (config.services.tailscale.enable) {
    # enable packet forwarding, to act as subnet router for tailscale
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    openFirewall = true;
  };
}
