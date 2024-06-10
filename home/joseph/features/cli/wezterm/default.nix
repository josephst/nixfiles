{ pkgs, config, ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      config.color_scheme = 'Catppuccin Frappe'
      config.default_prog = {
        '${pkgs.fish}/bin/fish', '-l'
      }

      config.font = wezterm.font 'Iosevka Term'
      config.initial_cols = 140
      config.initial_rows = 40

      return config
    '';
  };
}
