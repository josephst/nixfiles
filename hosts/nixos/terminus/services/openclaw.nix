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
    pkgs.google-chrome
    pkgs.himalaya
    pkgs.khal
    pkgs.vdirsyncer
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
