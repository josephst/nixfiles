{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  programs.fish = {
    enable = true;
    plugins = [ ];
    interactiveShellInit = ''
      ${lib.optionalString isDarwin "source ~/.config/op/plugins.sh #1password CLI"}
    '';

    shellAbbrs = {
      agf = "ag --nobreak --nonumbers --noheading . | fzf"; # fuzzy search file contents
      ls = "eza";
      ll = "exa -l";
      la = "eza -a";
      lt = "eza --tree";
      lla = "eza -la";
    };
  };
}
