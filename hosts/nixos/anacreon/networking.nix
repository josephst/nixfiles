_: {
  networking = {
    dhcpcd.enable = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    networks = {
      "10-uplink" = {
        matchConfig.Name = "ens3";
        address = [
          "2604:2dc0:101:200::538a/128"
        ];
        dhcpV4Config = {
          RouteMetric = 100;
          UseMTU = true;
        };
        linkConfig = {
          MTUBytes = "1500";
          RequiredForOnline = "routable";
        };
        networkConfig = {
          DHCP = "ipv4";
          DNS = [ "213.186.33.99" ];
          IPv6AcceptRA = false;
          LinkLocalAddressing = "ipv6";
        };
        routes = [
          {
            Destination = "2604:2dc0:101:200::1/64";
            Gateway = "::";
          }
          {
            Destination = "::/0";
            Gateway = "2604:2dc0:101:200::1";
          }
        ];
      };
    };
  };
}
