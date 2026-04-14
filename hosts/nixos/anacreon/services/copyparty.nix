{
  services = {
    copyparty = {
      enable = true;
      settings = {
        ansi = true;
        i = "127.0.0.1";
        no-reload = true;
      };
      volumes = {
        "/" = {
          path = "/var/lib/copyparty/share";
          access = {
            rwmd = "*";
          };
        };
      };
    };

    tailscale.serve.services.anacreon-copyparty = {
      endpoints = {
        "tcp:443" = "http://127.0.0.1:3923";
      };
    };
  };
}
