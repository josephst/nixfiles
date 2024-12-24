{...}: {
  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
    };
  };

  home.shellAliases.cat = "bat --paging=never";
}
