{ ... }:
{
  programs = {
    starship = {
      enable = true;
      settings = {
        command_timeout = 800;
        line_break = {
          disabled = true;
        };
      };
    };
  };
}
