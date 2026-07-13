_: {
  programs.zellij = {
    enable = true;
    attachExistingSession = true;
    layouts.default_layout = ./default_layout.kdl;
    settings = {
      default_shell = "fish";
      # theme = "catppuccin-frappe";
      default_layout = "default_layout";
    };

    enableBashIntegration = false;
    enableFishIntegration = true;
    enableZshIntegration = false;
  };
}
