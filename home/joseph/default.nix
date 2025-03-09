{ pkgs
, config
, osConfig
, lib
, inputs
, outputs
, ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  username = "joseph";

  # list of keys which can be used for key-based SSH authentication when logging in to another system
  # key is the hostname, value is the key
  #
  # these are unique per-system, to track which system is logging in to a particular server
  keys = import ../../keys;

  # ssh key used for signing Git commits
  # this key is shared among all systems the user can log in to
  # as it does not matter which device the git commit is being signed by (more interested in which *user* is signing)
  gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph-git-signing";

  inherit (osConfig.networking) hostName;

  userKey =
    if lib.hasAttr hostName keys.users.joseph then lib.getAttr hostName keys.users.joseph else null;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.hmModules.nix-index

    ./secrets
    ./features/base
    ./features/gui # this module will disable if config.myconfig.headless is true
    ./features/llm
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  myconfig.userSshKeys.identityFileText = userKey; # used in features/base/ssh.nix
  myconfig.userSshKeys.gitSigningKey = gitSigningKey;
  # myconfig.rclone.remotes = [ "onedrive" ]; # sync onedrive using rclone

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Home Manager configuration/ options
  home = {
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];

    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      EDITOR = "micro";
    };

    stateVersion = "22.11";

    shellAliases = {
      dig = "dog";
      copy = "rsync --archive --verbose --human-readable --partial --progress --modify-window=1"; # copy <source> <destination>
      external-ip = "dog +short myip.opendns.com @resolver1.opendns.com";
    };
  };

  xdg = {
    enable = true;

    userDirs = {
      enable = isLinux;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };

    configFile = {
      "ghostty/config".text = ''
        command = "${pkgs.fish}/bin/fish -l"

        theme = dark:catppuccin-frappe,light:catppuccin-latte
      '';
    };
  };

  # link nixpkgs-manual for quick reference
  home.file."Documents/nixpkgs-manual.html".source =
    "${pkgs.nixpkgs-manual}/share/doc/nixpkgs/manual.html";
}
