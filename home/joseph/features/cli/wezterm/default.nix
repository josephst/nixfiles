{pkgs, config, ...}:
let
  # potential workaround for nushell in wezterm not loading env vars properly
  wezterm-nushell = pkgs.writeShellScript "wezterm-nushell.sh" ''
  source /etc/static/bashrc
  source ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh

  exec ${pkgs.nushell}/bin/nu
'';
in {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      config.color_scheme = 'Catppuccin Frappe'
      config.default_prog = {
        '${pkgs.bash}/bin/bash',
        '--login',
        '-c',
        '${pkgs.nushell}/bin/nu --login --interactive'
      }

      config.font = wezterm.font 'Iosevka Term'
      config.initial_cols = 140
      config.initial_rows = 40

      return config
    '';
  };
}