{ config, pkgs, ... }:
{
  services.netdata = {
    package = pkgs.netdataCloud;
    enable = true;
    claimTokenFile = config.age.secrets.netdata_nixos_claim.path;
  };
}
