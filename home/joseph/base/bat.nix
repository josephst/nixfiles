{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  programs.bat = {
    enable = true;
    extraPackages =
      with pkgs.bat-extras;
      [
        batdiff
        batman
      ]
      # prettybat pulls Rustfmt/Rustc and Clang tooling into the closure, making
      # the installer image significantly larger.
      ++ lib.optional (osConfig.hostSpec.role != "installer") prettybat;
    config = {
      theme = "ansi";
    };
  };

  home.shellAliases.cat = "bat --paging=never";
}
