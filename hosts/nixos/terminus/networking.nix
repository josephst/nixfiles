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
        DHCP = "no";
        networkConfig = {
          Address = "192.168.1.10/24";
          Gateway = "192.168.1.1";
          DNS = [
            "127.0.0.1" # blocky listening here
            "::1"
            # "2606:4700:4700::1111" # in case self-hosted DNS fails, use Cloudflare
          ];
          MulticastDNS = true;
        };
        domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        linkConfig = {
          RequiredForOnline = "yes";
        };
        ipv6AcceptRAConfig = {
          UseDNS = false; # don't listen to the ipv6 DNS advertisements from DHCP server, use our own
        };
      };
    };
  };
}
