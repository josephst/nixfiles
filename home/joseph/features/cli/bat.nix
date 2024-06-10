_: {
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  home.shellAliases.cat = "bat --paging=never";
}
