{ lib, config, ... }:
{
  services.blocky = {
    enable = false; # 4/2/2024: no longer in use
    settings = {
      ports = {
        dns = [
          "127.0.0.1:53"
          "[::1]:53"
        ];
        http = 4000;
      };
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
        "https://dns.quad9.net/dns-query"
        "https://dns.google/dns-query"
      ];
      bootstrapDns = [
        {
          upstream = "https://one.one.one.one/dns-query";
          ips = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        }
        {
          upstream = "https://dns.quad9.net/dns-query";
          ips = [
            "9.9.9.9"
            "149.112.112.112"
          ];
        }
        {
          upstream = "https://dns.google/dns-query";
          ips = [
            "8.8.8.8"
            "8.8.4.4"
          ];
        }
      ];
      customDNS = {
        mapping = {
          # also resolves all subdomains (don't need an explicit wildcard)
          "terminus.josephstahl.com" = "192.168.1.10"; # right now, single homelab machine handles all queries
          "homelab.josephstahl.com" = "192.168.1.10";
        };
      };
      clientLookup.upstream = "192.168.1.1";
      queryLog.type = "none";
      # blocking = {
      #   denylists = {
      #     ads = [
      #       "https://small.oisd.nl/domainswild"
      #     ];
      #   };
      #   clientGroupsBlock = {
      #     default = [ "ads" ];
      #   };
      # };
    };
  };
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  systemd.services.blocky = lib.mkIf config.services.blocky.enable {
    after = [ "network.target" ];
    startLimitBurst = 10;
    startLimitIntervalSec = 60;
    serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_RAW" ]; # to bind 192.168.1.10 even if not yet assigned to the interface
      CapabilityBoundingSet = [ "CAP_NET_RAW" ];
      RestartSec = "5s";
    };
  };
}
