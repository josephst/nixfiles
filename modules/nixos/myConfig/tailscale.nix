{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.myConfig.tailscale;
in
{
  options.myConfig.tailscale = {
    enable = lib.mkEnableOption "tailscale";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optionals config.myConfig.gnome.enable [ pkgs.trayscale ];

    services.tailscale = {
      enable = true;
      # Enable caddy to acquire certificates from the tailscale daemon
      # - https://tailscale.com/blog/caddy
      permitCertUid = lib.mkIf config.services.caddy.enable config.services.caddy.user;
      openFirewall = true;
      useRoutingFeatures = lib.mkDefault "both";
    };
  };

  systemd.services.tailscaled.environment = {
    "TS_DEBUG_FIREWALL_MODE" = "auto";
  };
}
