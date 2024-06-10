{ config, ... }:
{
  # run tailscale up --accept-dns=false --ssh to start tailscale
  services.tailscale = {
    enable = true;
    permitCertUid = "caddy"; # allow caddy to fetch https certificates
    useRoutingFeatures = "both";
  };
}
