{
  services = {
    caddy = {
      enable = true;
      openFirewall = false;
      # Tailscale addresses are stable while this node remains registered.
      # Update both values if Anacreon is removed and re-created in the tailnet.
      # Caddy's systemd unit retries if the addresses are not ready at boot.
      globalConfig = ''
        default_bind 100.80.8.252 [fd7a:115c:a1e0::1636:a411]
      '';
    };
  };
}
