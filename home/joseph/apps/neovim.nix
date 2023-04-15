{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim".recursive = true;
  xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    owner = "AstroNvim";
    repo = "AstroNvim";
    rev = "v3.9.0";
    sha256 = "sha256-kFY6FBS5jmpzRks62PKJbAG8/uaOdeFJMt6snBJkzJM=";
  };
}
