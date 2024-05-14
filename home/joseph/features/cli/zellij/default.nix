{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
      theme = "catppuccin-frappe";
    };
    enableFishIntegration = true; # see settings in fish.nix
  };

  xdg.configFile."zellij/themes/catppuccin.kdl".source = ./catppuccin.kdl;
}
