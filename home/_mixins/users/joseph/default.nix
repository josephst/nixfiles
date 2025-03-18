{ config
, lib
, pkgs
, ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  programs = {
    gh = {
      enable = true;
      extensions = [ ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    git = {
      userEmail = "1269177+josephst@users.noreply.github.com";
      userName = "Joseph Stahl";
      signing = {
        signByDefault = true;
        format = "ssh";
      };
      extraConfig = {
        gpg = {
          ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
        };
      };
    };
  };

  # auth with github is managed by 1password on mac (instead of reading gh/hosts.yml)
  age = {
    secrets = lib.mkIf isLinux {
      "gh/hosts.yml" = {
        file = ./secrets/gh_hosts.yml.age;
        path = "${config.xdg.configHome}/gh/hosts.yml";
      };
    };
  };
}
