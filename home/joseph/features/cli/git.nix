{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop";
in
{
  programs.git = {
    enable = true;
    userEmail = "1269177+josephst@users.noreply.github.com";
    userName = "Joseph Stahl";
    signing = {
      key = signingKey;
      signByDefault = true;
    };
    aliases = {
      p = "pull --ff-only";
      ff = "merge --ff-only";
      graph = "log --decorate --oneline --graph";
      pushall = "!git remote | xargs -L1 git push --all";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
    };
    extraConfig = {
      credential.helper = lib.optionalString isDarwin "/usr/local/bin/git-credential-manager";
      gpg = {
        format = "ssh";
        ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };
      init.defaultBranch = "main";
      # Automatically track remote branch
      push.autoSetupRemote = true;
      pull.rebase = "true";
      rebase.autosquash = "true";
      # rebase.autostash = "true";
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

    package = if isDarwin then (pkgs.git.override { osxkeychainSupport = false; }) else pkgs.git;
  };

  home.file.".ssh/allowed_signers".text = ''
    1269177+josephst@users.noreply.github.com ${signingKey}
  '';
}
