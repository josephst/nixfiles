{ config, ... }:
{
  programs.bun = {
    enable = true;
    settings = {
      # TODO: figure out why Bun keeps ignoring this and putting files in ~/.cache/.bun instead of ~/.cache/bun
      #install = {
      #  globalDir = "${config.xdg.cacheHome}/bun/install/global";
      #  globalBinDir = "${config.xdg.binHome}";
      #  cache = {
      #    dir = "${config.xdg.cacheHome}/bun/cache";
      #  };
      #};
    };
  };
  home.sessionPath = [
    "${config.xdg.cacheHome}/.bun/bin" # add bun executables to local path
  ];
}
