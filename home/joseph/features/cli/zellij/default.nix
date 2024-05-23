{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
      theme = "catppuccin-frappe";
      default_layout = "default_layout";
    };
    enableFishIntegration = false; # see manual settings in fish.nix
  };

  home.sessionVariables = {
    ZELLIJ_AUTO_ATTACH = "true";
  };

  xdg.configFile."zellij/themes/catppuccin.kdl".source = ./catppuccin.kdl;
  xdg.configFile."zellij/layouts/default_layout.kdl".source = ./default_layout.kdl;
}
