_: {
  programs.eza = {
    enable = true;
    enableNushellIntegration = false;
    icons = "auto";
    extraOptions = [
      "--git"
      "--group-directories-first"
      "--header"
    ];
  };

  programs.fish.shellAbbrs = {
    cat = "bat"; # better cat
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    lt = "eza --tree";
    lla = "eza -la";
  };
}
