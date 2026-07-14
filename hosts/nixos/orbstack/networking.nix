{ lib, ... }:
{
  networking = {
    domain = "homelab.josephstahl.com";
    firewall.enable = false;
    networkmanager.enable = false; # networks are manually configured on orbstack

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    dhcpcd.enable = false;
    resolvconf.enable = false;
    useHostResolvConf = false;
    # useNetworkd = true;
    # useDHCP = false;
    # interfaces.eth0.useDHCP = true;
  };
  # OrbStack owns /etc/resolv.conf. These priorities intentionally override the
  # shared NixOS resolver policy without modifying the generated module.
  services.resolved.enable = lib.mkForce false;
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
