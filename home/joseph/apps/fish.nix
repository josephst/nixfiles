{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  programs.fish = {
    enable = true;
    plugins = [ ];
    interactiveShellInit =
      (
        if isDarwin then
          (
            "eval $(/opt/homebrew/bin/brew shellenv)\n"
            # + (builtins.readFile ./fish/iterm2_shell_integration.fish)
          )
        else
          ""
      )
      + ''
        # Configure auto-attach/exit to your likings (default is off).
        if test "$TERM_PROGRAM" != "vscode"
          set ZELLIJ_AUTO_ATTACH false
          set ZELLIJ_AUTO_EXIT true
          eval (zellij setup --generate-auto-start fish | string collect)
          if not set -q ZELLIJ
              if test "$ZELLIJ_AUTO_ATTACH" = "true"
                  zellij attach -c
              else
                  zellij
              end

              if test "$ZELLIJ_AUTO_EXIT" = "true"
                  kill $fish_pid
              end
          end
        end
      '';
    loginShellInit = lib.mkIf isDarwin "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /nix/var/nix/profiles/default/bin /run/current-system/sw/bin";
  };
}
