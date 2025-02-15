{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  programs.git = {
    enable = true;
    userEmail = "1269177+josephst@users.noreply.github.com";
    userName = "Joseph Stahl";
    signing = {
      signByDefault = true;
      format = "ssh";
    };
    aliases = {
      l = "log --pretty=oneline -n 50 --graph --abbrev-commit";
      p = "pull --ff-only";
      ff = "merge --ff-only";
      graph = "log --decorate --oneline --graph";
      pushall = "!git remote | xargs -L1 git push --all";
      undo = "reset HEAD~1 --mixed";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
    };
    extraConfig = {
      credential.helper = lib.mkIf isDarwin "/usr/local/bin/git-credential-manager";
      gpg = {
        ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      init.defaultBranch = "main";
      # Automatically track remote branch
      push.autoSetupRemote = true;
      fetch.prune = true;
      pull.rebase = true;
      rebase.autosquash = true;
      # delta options
      delta.navigate = true;
      merge.conflictstyle = "zdiff3";
      diff.colorMoved = "default";
      rerere.enabled = true;
    } // lib.optionalAttrs isLinux { credential.credentialStore = "cache"; };
    delta = {
      enable = true;
    };
    ignores = [
      # Compiled Python files
      "*.pyc"

      # Folder view configuration files
      ".DS_Store"
      "Desktop.ini"

      # Thumbnail cache files
      "._*"
      "Thumbs.db"

      # Files that might appear on external disks
      ".Spotlight-V100.Trashes"

      # Nix-specific
      ".devenv"
      ".direnv"
    ];
  };
}
