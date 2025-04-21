_: {
  programs.fish = {
    enable = true;
    plugins = [ ];

    shellAbbrs = {
      webshare = "python -m http.server 8080";
    };
  };
}
