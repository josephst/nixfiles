{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = false;
  };
}
