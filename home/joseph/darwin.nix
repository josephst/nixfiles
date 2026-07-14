{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  # 1Password CLI authorization requires the app integration installed by the
  # host's Homebrew configuration.
  onePasswordEnabled =
    osConfig ? homebrew && lib.elem "1password-cli" (map (item: item.name) osConfig.homebrew.casks);
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    programs.ghostty = {
      enable = true;
      package = null; # Installed with Homebrew; Home Manager owns only the configuration.
      settings = {
        command = lib.getExe pkgs.fish;
        theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
        keybind = "shift+enter=text:\\n";
      };
    };

    xdg.configFile."op/plugins.sh" = {
      enable = onePasswordEnabled;
      text = ''
        export OP_PLUGIN_ALIASES_SOURCED=1
        alias gh="op plugin run -- gh"
      '';
    };
  };
}
