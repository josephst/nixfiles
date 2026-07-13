# sane networking defaults
{
  config,
  lib,
  ...
}:
let
  isGraphicalRole = lib.elem config.hostSpec.role [
    "installer"
    "workstation"
  ];
  unmanagedInterfaces = lib.optionals config.services.tailscale.enable [ "tailscale0" ];

  # Trust the tailscale interface, if tailscale is enabled
  trustedInterfaces = lib.optionals config.services.tailscale.enable [ "tailscale0" ];

  FallbackDNS = [
    "1.1.1.1#one.one.one.one"
    "8.8.8.8"
  ];
in
{
  config = {
    systemd.network.enable = lib.mkDefault (!isGraphicalRole); # use systemd-networkd on non-graphical systems
    networking = {
      firewall = {
        enable = lib.mkDefault true;
        inherit trustedInterfaces;
      };
      networkmanager = lib.mkIf isGraphicalRole {
        # Use resolved for DNS resolution; tailscale MagicDNS requires it
        dns = "systemd-resolved";
        enable = lib.mkDefault true;
        unmanaged = unmanagedInterfaces;
        wifi.backend = "iwd";
      };
      nftables.enable = lib.mkDefault true;
      useNetworkd = lib.mkDefault true;
    };

    services = {
      resolved = {
        enable = true;
        settings = {
          Resolve = {
            Domains = [ "~." ];
            # Tailscale owns split DNS. Keep encrypted/validated fallback DNS
            # disabled here rather than implying it applies to MagicDNS.
            DNSOverTLS = "false";
            DNSSEC = "false";
            inherit FallbackDNS;
          };
        };
      };
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    users.users.${config.hostSpec.username}.extraGroups =
      lib.optionals config.networking.networkmanager.enable
        [
          "networkmanager"
        ];
  };
}
