_:
{
  programs.bun = {
    enable = true;
  };

  home.sessionPath = [
    "$HOME/.cache/.bun/bin"
  ];
}
