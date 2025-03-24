_: {
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
      # theme = "catppuccin-frappe";
      default_layout = "default_layout";
    };

    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  home.sessionVariables = {
    ZELLIJ_AUTO_ATTACH = "true";
  };

  xdg.configFile."zellij/layouts/default_layout.kdl".source = ./default_layout.kdl;
}
