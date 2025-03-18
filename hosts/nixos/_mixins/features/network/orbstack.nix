{hostname, ...}: {
  networking = {
    hostName = hostname;
    domain = "josephstahl.com";
    firewall.enable = false;
    # networkmanager.enable = true; # Easiest to use and most distros use this by default.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    dhcpcd.enable = false;
    useHostResolvConf = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };
  # systemd.services.NetworkManager-wait-online.enable = false; # causes problems with tailscale
  # systemd.network.wait-online.anyInterface = true;

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
