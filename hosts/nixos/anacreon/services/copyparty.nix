{
  services.copyparty = {
    enable = true;
    settings = {
      ansi = true;
      i = "0.0.0.0";
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
}
