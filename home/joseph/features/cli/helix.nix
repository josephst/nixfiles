{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "catppuccin_frappe";
    };

    languages.language-server = {
      nixd.command = "nixd";
    };

    languages.language = [
      {
        name = "nix";
        language-servers = ["nixd"];
        auto-format = true;
        formatter = {
          command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          args = [ "<" ];
        };
      }
      {
        name = "fish";
        auto-format = true;
        formatter.command = "${pkgs.fish}/bin/fish_indent";
      }
    ];
  };
}
