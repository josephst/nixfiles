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
      cat = "bat"; # better cat
      ls = "eza";
      ll = "exa -l";
      la = "eza -a";
      lt = "eza --tree";
      lla = "eza -la";
      man = "batman";
      webshare = "python -m http.server 8080";
    };
  };
}
