{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
    host = "0.0.0.0"; # all address to allow access via tailscale (which also handles auth)
  };

  networking.firewall.allowedTCPPorts = [ 11434 ];
}
