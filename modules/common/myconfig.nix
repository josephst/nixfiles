{
  lib,
  ...
}:
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

    # TODO: make these home-manager modules?
    myconfig.sshUserKey = lib.mkOption {
      description = "Public SSH key to use (to represent the user for ie authenticating to remote servers)";
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    myconfig.gitSigningKey = lib.mkOption {
      description = "Public SSH key corresponding to key used to sign Git commits";
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };
}
