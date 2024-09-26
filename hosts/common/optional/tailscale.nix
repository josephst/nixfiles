{ lib, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    package = pkgs.tailscale;
    useRoutingFeatures = lib.mkDefault "client";
    permitCertUid = "caddy"; # allow caddy to fetch https certificates
  };
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ]; # Facilitate firewall punching
  };
}
