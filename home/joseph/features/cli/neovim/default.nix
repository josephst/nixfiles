{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = false; # using helix

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      (nvim-treesitter.withPlugins (
        p: with p; [
          bash
          c
          nix
          python
          zig
        ]
      ))
      plenary-nvim
      gruvbox-material
      mini-nvim
      catppuccin-nvim
      # nvim-tree-lua
    ];
  };

  xdg.configFile."nvim/init.lua".source = ./init.lua;
}
