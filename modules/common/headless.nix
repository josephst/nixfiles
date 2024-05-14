{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myconfig.headless;
in
with lib;
{
  meta.maintainers = [ maintainers.josephst ];

  options = {
    myconfig.headless = mkOption {
      description = "headless (don't install GUI apps)";
      default = true;
      type = types.bool;
    };
  };

  # no config (other parts of the config will look at config.myconfig.headless to enable/disable sections)
}
