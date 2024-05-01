{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0:11434"; # allow access via tailscale
  };

  networking.firewall.allowedTCPPorts = [
    11434
  ];
}
