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

    xdg.configFile."npm/npmrc" = {
      text = cfg.npmrc;
      # Ensure the directory exists
      # Note: home-manager doesn't have a dedicated mkｄir option for xdg.configFile
      # but it typically handles directory creation automatically.
      # If not, a separate home.file entry might be needed for the directory,
      # or a more direct approach using pkgs.runCommand.
      # However, for npmrc, npm itself might create the directory if it doesn't exist.
      # We'll rely on standard home-manager behavior first.
    };

    # Set NPM_CONFIG_USERCONFIG environment variable
    # This ensures npm uses the specified config file.
    # See https://docs.npmjs.com/cli/v10/using-npm/config#npmrc-files
    home.sessionVariables = {
      NPM_CONFIG_USERCONFIG = "\${config.xdg.configHome}/npm/npmrc";
    };
  };
}
