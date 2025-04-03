_: {
  networking.domain = "homelab.josephstahl.com";
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "enp5s0" ];
  };
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
        };
        # domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        linkConfig = {
          RequiredForOnline = "routable";
          Multicast = true;
        };
      };
    };
  };
}
