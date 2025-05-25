{ pkgs, config, ... }:
{
  home.packages = [ pkgs.aider-chat ];

  age.secrets."aider.conf.yml" = {
    file = ../../secrets/aider.conf.yml.age;
    path = "${config.home.homeDirectory}/.aider.conf.yml";
  };

  programs.git.ignores = [ ".aider*" ];
}
