_: {
  networking.domain = "homelab.josephstahl.com";
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;

    networks = {
      "10-lan" = {
        matchConfig.Name = "enp5s0";
        DHCP = "yes";
        networkConfig = {
          # Address = "192.168.1.10/24";
          # Gateway = "192.168.1.1";
          DNS = [
            # "127.0.0.1" # blocky listening here
            # "::1"
            "1.1.1.1"
            "1.0.0.1"
          ];
          MulticastDNS = true;
          IPv6AcceptRA = true;
        };
        domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        linkConfig = {
          RequiredForOnline = "routable";
          Multicast = true;
        };
        ipv6AcceptRAConfig = {
          UseDNS = false; # don't listen to the ipv6 DNS advertisements from DHCP server, use our own
        };
      };
    };
  };
}
