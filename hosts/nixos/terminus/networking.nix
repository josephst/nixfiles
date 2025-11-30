{ ... }:
{
  networking = {
    domain = "homelab.josephstahl.com";
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;

    links = {
      "50-wired" = {
        matchConfig = {
          MACAddress = "9c:6b:00:3e:0a:c7";
        };
        linkConfig = {
          WakeOnLan = "magic"; # wake for magic packet
        };
      };
    };

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
