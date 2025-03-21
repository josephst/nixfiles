_:
{
  programs.fish = {
    enable = true;
    plugins = [ ];

    shellAbbrs = {
      cat = "bat"; # better cat
      ls = "eza";
      ll = "exa -l";
      la = "eza -a";
      lt = "eza --tree";
      lla = "eza -la";
      webshare = "python -m http.server 8080";
    };
  };
}
