{ pkgs, lib, config, age, ... }:
{
  programs.gh = {
    enable = true;
    extensions = [];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # auth with github is managed by 1password on mac (instead of reading gh/hosts.yml)
  age = {
    secrets = lib.mkIf (pkgs.stdenv.isLinux) {
      "gh/hosts.yml" = {
        file = ../../secrets/gh_hosts.yml.age;
        path = "${config.xdg.configHome}/gh/hosts.yml";
      };
    };
  };
}
