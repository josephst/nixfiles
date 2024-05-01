{
  pkgs,
  lib,
  config,
  ...
}:
let
  fqdn = config.networking.fqdn;
in
{
  services.prowlarr = {
    enable = true;
  };

  services.caddy.virtualHosts."prowlarr.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:9696
    '';
    useACMEHost = fqdn;
  };

  # system.activationScripts.prowlarr = {
  #   # may need to restart prowlarr (systemctl restart [prowlarr]) after this
  #   text = ''
  #     if [[ -e /var/lib/private/prowlarr/config.xml ]]; then
  #       # file exists, modify it
  #       ${lib.getBin pkgs.gnused}/bin/sed -i 's/<AuthenticationMethod>None/<AuthenticationMethod>External/g' /var/lib/private/prowlarr/config.xml
  #     fi
  #     '';
  # };
}
