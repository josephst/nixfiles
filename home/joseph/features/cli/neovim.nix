{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim".recursive = true;
  xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    owner = "AstroNvim";
    repo = "AstroNvim";
    rev = "v4.6.7";
    hash = "sha256-jvQdFwE2eKe3pmTJtM/Sro0DMirS+QE17w8/CvpXRBo=";
  };
}
