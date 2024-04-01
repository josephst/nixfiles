{ pkgs, config, ... }:
let
  inherit (config.networking) hostName;
in
{
  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi8;
    openFirewall = true;
  };
}
