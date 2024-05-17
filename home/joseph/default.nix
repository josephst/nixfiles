# home manager config
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  username = "joseph";
in
{
  imports = [
    ./features/cli
    ./features/gui # this module will disable if config.myconfig.headless is true
    ./features/llm
  ] ++ (builtins.attrValues (import ../../modules/home-manager/default.nix));

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
