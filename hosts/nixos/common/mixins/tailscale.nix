{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostSpec = config.hostSpec;
in
{
  environment.systemPackages = lib.optional (hostSpec.desktop != null) pkgs.trayscale;

  services.tailscale = {
    enable = true;
    # Enable caddy to acquire certificates from the tailscale daemon
    # - https://tailscale.com/blog/caddy
    permitCertUid = lib.mkIf config.services.caddy.enable config.services.caddy.user;
    openFirewall = true;
    useRoutingFeatures = lib.mkDefault "both";
    extraUpFlags = [ "--ssh" ];
  };

  systemd.services.tailscaled.environment = {
    "TS_DEBUG_FIREWALL_MODE" = "auto";
  };
}
