# home manager config
{
  pkgs,
  config,
  osConfig,
  options,
  lib,
  agenix,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  username = "joseph";

  # list of keys which can be used for key-based SSH authentication when logging in to another system
  # key is the hostname, value is the key
  #
  # these are unique per-system, to track which system is logging in to a particular server
  keys = {
    "Josephs-MacBook-Air" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air";
    "nixos" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBTyMi+E14e8/droY9+Xg7ORNMMdgH1i6LsfDyKZSy4 joseph@nixos-proxmox";
  };
  # ssh key used for signing Git commits
  # this key is shared among all systems the user can log in to
  # as it does not matter which device the git commit is being signed by (more interested in which *user* is signing)
  gitSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph-git-signing";

  hostName = osConfig.networking.hostName;

  userKey = if lib.hasAttr hostName keys
    then lib.getAttr hostName keys
    else null;
in
{
  imports = [
    agenix.homeManagerModules.default
    ../../modules/home-manager

    ./features/cli
    ./features/gui # this module will disable if config.myconfig.headless is true
    ./features/llm
  ];

  # new Agenix configuration which is *user-specific* (DISTINCT from the system Agenix config)
  age = {
    identityPaths = [
      "~/.ssh/agenix"
    ] ++ config.age.identityPaths;
  };

  myconfig.userSshKeys.identityFileText = userKey; # used in features/cli/ssh.nix
  myconfig.userSshKeys.gitSigningKey = gitSigningKey;

  # Home Manager configuration/ options
  home = {
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];

    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };

    stateVersion = "22.11";

    shellAliases = {
      copy = "rsync --archive --verbose --human-readable --partial --progress --modify-window=1"; # copy <source> <destination>
    };
  };

  xdg = {
    enable = true;
    configFile = {
      # put various config files here (".text = builtins.readFile "foobar" or .source = )
    };

    userDirs = {
      enable = isLinux;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };
}
