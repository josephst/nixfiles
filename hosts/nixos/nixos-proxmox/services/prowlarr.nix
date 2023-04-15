{
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.prowlarr = {
    enable = true;
  };

  services.caddy.virtualHosts."prowlarr.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:9696
    '';
    useACMEHost = fqdn;
  };
}
