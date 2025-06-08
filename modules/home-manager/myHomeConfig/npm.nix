{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHomeConfig.npm;
in
{
  options.myHomeConfig.npm = {
    enable = lib.mkEnableOption "npm global config";

    package = lib.mkPackageOption pkgs [ "nodePackages" "npm" ] {
      example = "nodePackages_13_x.npm";
    };

    npmrc = lib.mkOption {
      type = lib.types.lines;
      description = ''
        User npm configuration.
        See <https://docs.npmjs.com/misc/config>.
        This will be written to $XDG_CONFIG_HOME/npm/npmrc.
      '';
      default = ''
        prefix = ''${HOME}/.npm
      '';
      example = ''
        prefix = ''${HOME}/.npm
        https-proxy=proxy.example.com
        init-license=MIT
        init-author-url=https://www.npmjs.com/
        color=true
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # use binaries from `prefix`
    home.sessionPath = [
      "$HOME/.npm/bin"
    ];

    xdg.configFile."npm/npmrc" = {
      text = cfg.npmrc;
      # xdg.configFile."npm/npmrc" ensures that the parent directory
      # (e.g., "${config.xdg.configHome}/npm") is created if it doesn't exist
      # before writing the npmrc file.
    };

    # Set NPM_CONFIG_USERCONFIG environment variable
    # This ensures npm uses the specified config file.
    # See https://docs.npmjs.com/cli/v10/using-npm/config#npmrc-files
    home.sessionVariables = {
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    };
  };
}
