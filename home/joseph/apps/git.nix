{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  programs.git = {
    enable = true;
    userEmail = "1269177+josephst@users.noreply.github.com";
    userName = "Joseph Stahl";
    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop";
    signing.signByDefault = isDarwin; # only sign on macOS for now (simplicity)
    extraConfig = {
      credential.helper = lib.optionalString isDarwin "/usr/local/bin/git-credential-manager";
      credential.credentialStore = lib.optionalString isLinux "cache"; # use in-memory cache on Linux
      gpg.format = "ssh";
      gpg.ssh.program = lib.optionalString isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      init.defaultBranch = "main";
      pull.rebase = "true";
      # delta options
      delta.navigate = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
    delta = {
      enable = true;
      options = {
      };
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

    package =
      if isDarwin
      then (pkgs.git.override {osxkeychainSupport = false;})
      else pkgs.git;
  };
}
