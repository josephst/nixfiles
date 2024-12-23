{ lib, config, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = lib.mkDefault "client";
    permitCertUid =
      if config.services.caddy.enable
      then config.services.caddy.user else null; # allow caddy to fetch https certificates
  };
}
