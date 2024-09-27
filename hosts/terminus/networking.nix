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
          DNS = " 192.168.1.10";
          # DNS = "1.1.1.1 8.8.8.8";

          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
      "20-tailscale-ignore" = {
        matchConfig.name = "tailscale*";
        linkConfig = {
          Unmanaged = "yes";
          RequiredForOnline = false;
        };
      };
    };
  };
}
