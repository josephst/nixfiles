{ pkgs, osConfig, ... }:
{
  programs.gh = {
    enable = true;
    extensions = [];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  xdg.configFile."gh/hosts.yml".source = osConfig.age.secrets."gh/hosts.yml".path;
}
