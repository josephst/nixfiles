{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [ ];

    shellAbbrs = {
      webshare = "${pkgs.python3}/bin/python -m http.server 8080";
    };
  };
}
