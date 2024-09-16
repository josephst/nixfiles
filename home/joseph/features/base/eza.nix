_: {
  programs.eza = {
    enable = true;
    icons = true;
  };
  home.shellAliases.lt = "eza --tree --level=2 --long --icons --git";
}
