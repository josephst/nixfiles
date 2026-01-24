_: {
  virtualisation = {
    incus = {
      enable = true;
      ui.enable = true;
      preseed = {
        networks = [
          {
            config = {
              "ipv4.address" = "auto";
            };
            name = "incusbr0";
            type = "bridge";
          }
        ];
        profiles = [
          {
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                size = "35GiB";
                type = "disk";
              };
            };
            name = "default";
          }
        ];
        storage_pools = [
          {
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
            driver = "dir";
            name = "default";
          }
        ];
      };
    };
  };
  networking.nftables.enable = true;
  networking.firewall.allowedTCPPorts = [ 8443 ];
  networking.firewall.trustedInterfaces = [ "incusbr0" ];
}
