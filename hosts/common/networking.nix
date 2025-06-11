# modules/common/networking-options.nix
{ config, ... }:
{
  config = {
    networking = {
      inherit (config.hostSpec) hostName;
    };
  };
}
