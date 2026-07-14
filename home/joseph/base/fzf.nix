_: {
  programs.fzf = {
    enable = true;
    # Home Manager's supported way to let Atuin own the Ctrl-R binding.
    historyWidget.command = "";
    colors = {
      fg = "-1";
      bg = "-1";
      hl = "#5fff87";
      "fg+" = "-1";
      "bg+" = "-1";
      "hl+" = "#ffaf5f";
      pointer = "#ff87d7";
      info = "#af87ff";
      spinner = "#ff87d7";
      # header = ;
      prompt = "#5fff87";
      marker = "#ff87d7";
    };
  };
}
