{ config, pkgs, ... }:
{
  age.secrets.netdata_nixos_claim = {
    file = ../secrets/netdata_nixos_claim.age;
  };

  services.netdata = {
    package = pkgs.netdataCloud;
    enable = true;
    claimTokenFile = config.age.secrets.netdata_nixos_claim.path;
  };
}
