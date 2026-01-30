{
  config,
  ...
}:
let
  inherit (config.networking) domain;
in
{
  services.caddy.virtualHosts = {
    "openclaw.${domain}" = {
      extraConfig = ''
        reverse_proxy http://localhost:18789
      '';
      useACMEHost = domain;
    };
  };
}
