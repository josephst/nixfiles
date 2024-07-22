{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      nimlangserver
      nixd
      nixfmt-rfc-style
      fish
      zls
    ];

    settings = {
      theme = "catppuccin_frappe";
    };

    languages.language-server = {
      nixd.command = "nixd";
    };

    languages.language = [
      {
        name = "nix";
        language-servers = [ "nixd" ];
        auto-format = true;
        formatter = {
          command = "nixfmt";
        };
      }
      {
        name = "fish";
        auto-format = true;
        formatter.command = "fish_indent";
      }
    ];
  };
}
