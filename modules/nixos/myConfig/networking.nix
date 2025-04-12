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
in
{
  imports = [
    ../../common/myConfig/networking.nix
  ];

  config = {
    networking = {
      firewall = {
        enable = lib.mkDefault true;
        inherit trustedInterfaces;
      };
      networkmanager = lib.mkIf config.myConfig.gnome.enable {
        # Use resolved for DNS resolution; tailscale MagicDNS requires it
        dns = "systemd-resolved";
        enable = true;
        unmanaged = unmanagedInterfaces;
        wifi.backend = "iwd";
      };
      nftables.enable = lib.mkDefault true;
      useNetworkd = lib.mkDefault true;
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

    users.users.${config.myConfig.user.username}.extraGroups = lib.optionals config.networking.networkmanager.enable [
      "networkmanager"
    ];
  };
}
