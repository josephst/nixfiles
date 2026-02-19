{
  config,
  pkgs,
  ...
}:
let
  inherit (config.networking) domain;
in
{
  environment.systemPackages = [
    pkgs.himalaya
  ];
  services.caddy.virtualHosts = {
    "openclaw.${domain}" = {
      extraConfig = ''
        reverse_proxy http://localhost:18789
      '';
      useACMEHost = domain;
    };
  };
}
