{ config
, ...
}:
let
  cfg = config.myConfig.networking;
in
{
  imports = [
    ../../common/myConfig/networking.nix
  ];
  config = {
    networking = {
      computerName = cfg.hostname;
    };
  };
}
