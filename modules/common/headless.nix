{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myconfig.headless;
in
{
  meta.maintainers = [ lib.maintainers.josephst ];

  options = {
    myconfig.headless = lib.mkOption {
      description = "headless (don't install GUI apps)";
      default = true;
      type = lib.types.bool;
    };
  };

  # no config (other parts of the config will look at config.myconfig.headless to enable/disable sections)
}
