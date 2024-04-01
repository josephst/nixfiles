{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  programs.git = {
    enable = true;
    userEmail = "1269177+josephst@users.noreply.github.com";
    userName = "Joseph Stahl";
    signing.signByDefault = isDarwin; # only sign on macOS for now (simplicity)
    extraConfig = {
      credential.helper = lib.optionalString isDarwin "/usr/local/bin/git-credential-manager";
      gpg.format = "ssh";
      gpg.ssh.program = lib.optionalString isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
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
    ];

    package = if isDarwin then (pkgs.git.override { osxkeychainSupport = false; }) else pkgs.git;
  };
}
