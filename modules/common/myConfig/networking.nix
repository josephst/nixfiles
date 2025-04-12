# modules/common/networking-options.nix
{ lib, config, ... }:
let
  cfg = config.myConfig.networking;
in
{
  options.myConfig.networking = {
    hostname = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The hostname of the machine.";
    };
  };

  config = {
    assertions = [{
      assertion = cfg.hostname != null;
      message = "You must set a hostname.";
    }];

    networking = {
      hostName = cfg.hostname;
    };
  };
}
