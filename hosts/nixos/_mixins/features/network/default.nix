{
  config,
  hostname,
  isWorkstation,
  lib,
  username,
  ...
}:
let
  unmanagedInterfaces =
    lib.optionals config.services.tailscale.enable [ "tailscale0" ];

  # Trust the tailscale interface, if tailscale is enabled
  trustedInterfaces =
    lib.optionals config.services.tailscale.enable [ "tailscale0" ];

  fallbackDns = ["1.1.1.1#one.one.one.one"];
in {
  imports = lib.optional (builtins.pathExists (./. + "/${hostname}.nix")) ./${hostname}.nix;

  networking = {
    firewall = {
      enable = true;
      inherit trustedInterfaces;
    };
    hostName = hostname;
    domain = "homelab.josephstahl.com";
    networkmanager = lib.mkIf isWorkstation {
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

  users.users.${username}.extraGroups = lib.optionals config.networking.networkmanager.enable [
    "networkmanager"
  ];
}
