{pkgs, ...}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.fish = {
    enable = true;
    shellAliases = {
      top = "${pkgs.bottom}/bin/btm";
      cat = "${pkgs.bat}/bin/bat --paging=never";
    };
    plugins = [
      # {
      #   name = "fzf.fish";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "PatrickF1";
      #     repo = "fzf.fish";
      #     rev = "039a86d";
      #     sha256 = "1shlvlss47gixgd5kxm27qklns2n2aq2dy7h3b4vsb3kfalm58w5";
      #   };
      # }
    ];
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
          eval (zellij setup --generate-auto-start fish | string collect)
        end
      '';
    loginShellInit =
      if isDarwin
      then "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /nix/var/nix/profiles/default/bin /run/current-system/sw/bin"
      else "";
  };
}
