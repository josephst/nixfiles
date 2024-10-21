_: {
  programs.eza = {
    enable = true;
    icons = "auto";
  };
  home.shellAliases.lt = "eza --tree --level=2 --long --icons --git";
}
