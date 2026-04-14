{
  services = {
    backrest = {
      enable = true;
      bindAddress = "127.0.0.1";
    };

    tailscale.serve.services.anacreon-backrest = {
      endpoints = {
        "tcp:443" = "http://127.0.0.1:9898";
      };
    };
  };
}
