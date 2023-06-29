{pkgs, ...}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.fish = {
    enable = true;
    plugins = [];
    interactiveShellInit =
      (
        if isDarwin
        then
          (
            "eval $(/opt/homebrew/bin/brew shellenv)\n"
            # + (builtins.readFile ./fish/iterm2_shell_integration.fish)
          )
        else ""
      )
      + ''
        if test "$TERM_PROGRAM" != "vscode"; and type -q zellij; and status is-interactive
          set -gx ZELLIJ_AUTO_ATTACH true
          set -gx ZELLIJ_AUTO_EXIT true
        end
      '';
    loginShellInit =
      if isDarwin
      then "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /nix/var/nix/profiles/default/bin /run/current-system/sw/bin"
      else "";
  };
}
