{
  services = {
    caddy = {
      enable = true;
      openFirewall = false;
    };

    tailscale.serve.enable = true;
  };
}
