{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.netdata = {
    enable = true;
  };
}
