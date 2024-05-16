{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myconfig;
in
{
  meta.maintainers = [ lib.maintainers.josephst ];

  options = {
    myconfig.gui.enable = lib.mkEnableOption {
      description = "headless (don't install GUI apps)";
      default = false;
      type = lib.types.bool;
    };

    myconfig.llm.enable = lib.mkEnableOption {
      description = "LLM support";
      default = false;
      type = lib.types.bool;
    };
  };

  # no config (other parts of the config will look at config.myconfig.headless to enable/disable sections)
}
