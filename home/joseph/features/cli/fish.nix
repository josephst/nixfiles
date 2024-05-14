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
        if test "$TERM_PROGRAM" != "vscode"
          set ZELLIJ_AUTO_ATTACH true
        end
    '';
  };
}
