{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
    };
  };

  home.packages = with pkgs; [
    bat-extras.batman
  ];

  home.shellAliases.cat = "bat --paging=never";
}
