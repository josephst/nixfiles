{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      fish
      nimlangserver
      nixd
      nixfmt-rfc-style
      shellcheck
      zls
    ];

    settings = {
      theme = "catppuccin_frappe";
      editor = {
        line-number = "relative";
        rulers = [ 80 120 ];
        cursorline = true;
        auto-info = true;
        color-modes = true;

        lsp = {
          display-messages = true;
          display-inlay-hints	= true;
        };

        statusline = {
          left = ["mode" "spinner" "file-modification-indicator" "read-only-indicator"];
          center = [ "version-control" "file-name"];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          separator = "│";
          mode = {
            normal = "NORMAL";
            insert = "-- INSERT --";
            select = "-- SELECT --";
          };
        };
      };
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
