_: {
  networking = {
    hostName = "terminus";
    hostId = "e2dfd738"; # head -c 8 /etc/machine-id
    domain = "homelab.josephstahl.com";

    # networkmanager - disabled, use systemd-networkd instead
    networkmanager.enable = false; # using systemd-networkd
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;

    networks = {
      "10-lan" = {
        matchConfig.Name = "enp5s0";
        networkConfig = {
          Address = "192.168.1.10/24";
          Gateway = "192.168.1.1";
          DNS = [
            "192.168.1.10"
            "::1"
          ];
          MulticastDNS = true;
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        linkConfig.RequiredForOnline = "yes";
        dhcpV6Config = {
          UseDNS = false; # don't listen to the ipv6 DNS advertisements from DHCP server, use our own
        };
      };
    };
  };
}
