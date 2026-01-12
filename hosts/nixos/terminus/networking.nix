_:
{
  networking = {
    domain = "homelab.josephstahl.com";
    interfaces = {
      "enp5s0" = {
        wakeOnLan.enable = true;
      };
    };
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
          IPv6AcceptRA = true;
        };
        # domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
        linkConfig = {
          RequiredForOnline = "routable";
        };
      };
    };
  };

  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    openFirewall = true;
  };
}
