{ config, ... }:
{
  programs.bun.enable = true;

  # Preserve Bun's existing global-install location. Moving this to XDG data/bin
  # directories would require migrating or reinstalling globally installed tools.
  home.sessionPath = [
    "${config.xdg.cacheHome}/.bun/bin"
  ];
}
