{
  services = {
    caddy = {
      enable = true;
      openFirewall = false;
      globalConfig = ''
        default_bind 100.80.8.252 [fd7a:115c:a1e0::1636:a411]
      '';
    };
  };
}
