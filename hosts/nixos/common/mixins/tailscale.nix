{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) hostSpec;
in
{
  environment.systemPackages = lib.optional (lib.elem hostSpec.role [
    "installer"
    "workstation"
  ]) pkgs.trayscale;

  services.tailscale = {
    enable = true;
    # Enable caddy to acquire certificates from the tailscale daemon
    # - https://tailscale.com/blog/caddy
    permitCertUid = lib.mkIf config.services.caddy.enable config.services.caddy.user;
    openFirewall = true;
    useRoutingFeatures = lib.mkDefault "both";
    extraSetFlags = [ "--ssh" ];
  };

  systemd.services.tailscaled.environment = {
    # Unset currently selects iptables; "auto" lets Tailscale detect and use
    # the nftables backend enabled by the shared NixOS networking module.
    "TS_DEBUG_FIREWALL_MODE" = "auto";
  };
}
