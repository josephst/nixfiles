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

      # don't launch zellij in VSCode terminal
      if test "$TERM_PROGRAM" != "vscode"
        set ZELLIJ_AUTO_ATTACH true
        eval (${lib.getExe pkgs.zellij} setup --generate-auto-start fish | string collect)
      end
    '';
  };
}
