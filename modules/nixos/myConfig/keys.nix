{ config, lib, ... }:

{
  options.myConfig.keys = lib.mkOption {
    type = lib.types.nullOr lib.types.attrs;
    default = null;
    description = "SSH keys for this system and its users";
  };

  config = { };
}
