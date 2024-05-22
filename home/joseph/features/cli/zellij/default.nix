{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
      theme = "catppuccin-frappe";
    };
    enableFishIntegration = false; # see manual settings in fish.nix
  };

  home.sessionVariables = {
    ZELLIJ_AUTO_ATTACH = "true";
  };

  xdg.configFile."zellij/themes/catppuccin.kdl".source = ./catppuccin.kdl;
}
