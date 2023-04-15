{
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) hostName;
in {
  services.tailscale = {
    enable = true;
    permitCertUid = "caddy"; # allow caddy to fetch https certificates
  };
}
