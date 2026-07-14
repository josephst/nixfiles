_: {
  services = {
    copyparty = {
      enable = true;
      settings = {
        ansi = true;
        i = "127.0.0.1";
        # Tailscale Serve strips client-supplied identity headers before
        # injecting the authenticated tailnet user's login.
        idp-h-usr = "Tailscale-User-Login";
        no-reload = true;
        xff-src = "127.0.0.1";
      };
      volumes = {
        "/" = {
          path = "/var/lib/copyparty/share";
          access = {
            r = "*";
            rwmd = "@acct";
          };
        };
      };
    };
  };
}
