{
  config,
  pkgs,
  ...
}:
let
  inherit (config.networking) domain;
in
{
  virtualisation.podman.enable = true;
  services.caddy.virtualHosts = {
    "openclaw.${domain}" = {
      extraConfig = ''
        reverse_proxy http://localhost:18789
      '';
      useACMEHost = domain;
    };
  };
}
