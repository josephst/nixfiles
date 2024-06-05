{ pkgs, config, ... }:
let
  address = [
    "/nixos.josephstahl.com/192.168.1.10"
    "/proxmox.josephstahl.com/192.168.1.8"
  ];
in
{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false; # let systemd-resolved act as cache for local queries
    settings = {
      listen-address = [ "192.168.1.10" ];
      interface = "enp6s18";
      bind-interfaces = true;
      no-resolv = true; # use specific upstreams, as the /etc/resolv.conf file just points to systemd-resolved (which points back to dnsmasq...)
      no-hosts = true; # ignore hosts file, which keeps telling other devices that nixos.josephstahl.com is at 127.0.0.2
      cache-size = 500;
      server = [
        "8.8.8.8"
        "1.1.1.1"
        "8.8.4.4"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
      inherit address;
      dnssec = true;
      conf-file = "${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf";
    };
  };
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
