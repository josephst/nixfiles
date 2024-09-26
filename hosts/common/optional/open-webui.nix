let
  # inherit (config.networking) domain;
in
{
  services.open-webui = {
    enable = false; # TODO: reenable when no longer broken (0.3.21 is broken)
    openFirewall = true;
    port = 8082;
  };

  # services.caddy.virtualHosts."open-webui.${domain}" = {
  #   extraConfig = ''
  #     reverse_proxy http://localhost:8082
  #     encode gzip
  #   '';
  #   useACMEHost = domain;
  # };
}
