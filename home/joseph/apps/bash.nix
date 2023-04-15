{pkgs, ...}: {
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
  };
}
