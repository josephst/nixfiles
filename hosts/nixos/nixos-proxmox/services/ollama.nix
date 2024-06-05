_: {
  services.ollama = {
    enable = true;
    host = "0.0.0.0"; # all address to allow access via tailscale (which also handles auth)
    # listens on 11434 by default
  };

  networking.firewall.allowedTCPPorts = [ 11434 ];
}
