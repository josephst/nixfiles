{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
    };
    # enableFishIntegration = true; # see settings in fish.nix
  };
}
