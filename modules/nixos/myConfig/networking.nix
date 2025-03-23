# sane networking defaults
{ config
, lib
, ...
}:
let
  unmanagedInterfaces =
    lib.optionals config.services.tailscale.enable [ "tailscale0" ];

  # Trust the tailscale interface, if tailscale is enabled
  trustedInterfaces =
    lib.optionals config.services.tailscale.enable [ "tailscale0" ];

  fallbackDns = [ "1.1.1.1#one.one.one.one" ];

  cfg = config.myConfig;
in
{
  options.myConfig = {
    hostname = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The hostname of the machine.";
    };
  };

  config = {
    assertions = [{
      assertion = cfg.hostname != null;
      message = "You must set a hostname.";
    }];

    networking = {
      firewall = {
        enable = lib.mkDefault true;
        inherit trustedInterfaces;
      };
      hostName = cfg.hostname;
      domain = lib.mkDefault "homelab.josephstahl.com";
      networkmanager = lib.mkIf cfg.gnome.enable {
        # Use resolved for DNS resolution; tailscale MagicDNS requires it
        dns = "systemd-resolved";
        enable = true;
        unmanaged = unmanagedInterfaces;
        wifi.backend = "iwd";
      };
      nftables.enable = lib.mkDefault true;
      useDHCP = lib.mkDefault true;
      useNetworkd = true;
    };

    services = {
      resolved = {
        enable = true;
        domains = [ "~." ];
        dnsovertls = "opportunistic";
        dnssec = "false";
        inherit fallbackDns;
      };
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    users.users.${config.myConfig.user}.extraGroups = lib.optionals config.networking.networkmanager.enable [
      "networkmanager"
    ];
  };
}
