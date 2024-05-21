{ lib, ... }:
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

    # TODO: myconfig.mainUser option, to set username
  };
}
