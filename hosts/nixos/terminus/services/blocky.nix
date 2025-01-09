{
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = [
          "192.168.1.10:53"
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
          "terminus.josephstahl.com" = "192.168.1.10"; # right now, single homelab machine handles all queries except Proxmox
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

  systemd.services.blocky.after = [ "network.target" ];
}
