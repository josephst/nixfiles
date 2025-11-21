_: {
  programs.bun = {
    enable = true;
  };

  home.sessionPath = [
    "$HOME/.cache/.bun/bin" # add bun executables to local path
  ];
}
