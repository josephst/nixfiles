{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      prettybat
    ];
    config = {
      theme = "ansi";
    };
  };

  home.shellAliases.cat = "bat --paging=never";
}
