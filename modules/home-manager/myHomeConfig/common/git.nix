{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  programs.git = {
    enable = true;
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
      init.defaultBranch = "main";
      # Automatically track remote branch
      push = {
        autoSetupRemote = true;
        default = "simple";
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      pull = {
        rebase = true;
      };
      brach.sort = "-committerdate";
      rebase.autosquash = true;
      # delta options
      delta.navigate = true;
      merge.conflictstyle = "zdiff3";
      diff = {
        colorMoved = "plain";
        algorithm = "histogram";
        renames = "true";
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      help.autocorrect = "prompt";
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
