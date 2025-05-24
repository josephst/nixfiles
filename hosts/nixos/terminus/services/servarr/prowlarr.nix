{ config, inputs, ... }:
let
  inherit (config.networking) domain;
in
{

  # TODO: prowlarr config broken upstream, go back to unstable once fixed
  disabledModules = [
    "services/misc/servarr/prowlarr.nix"
  ];
  imports = [
    "${inputs.nixpkgs-stable}/nixos/modules/services/misc/servarr/prowlarr.nix"
  ];

  services.prowlarr = {
    enable = true;
  };

  services.caddy.virtualHosts."prowlarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:9696
    '';
    useACMEHost = domain;
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
