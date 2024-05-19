{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    extensions = [];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
