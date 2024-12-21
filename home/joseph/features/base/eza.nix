_: {
  programs.eza = {
    enable = true;
    icons = "auto";
    extraOptions = [
      "--git"
      "--group-directories-first"
      "--header"
    ];
  };
  home.shellAliases.lt = "eza --tree --level=2 --long --icons --git";
}
