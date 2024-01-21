{
  pkgs,
  config,
  ...
}: {
  programs.alacritty = {
    # also declared as a homebrew cask
    # duplication is so that configuration can be done here, and
    # the homebrew cask provides a nice app for Finder/ Spotlight
    enable = true;
    settings = {
      shell = "${pkgs.fish}/bin/fish";
      window = {
        opacity = 1;
        dynamic_title = true;
        dynamic_padding = true;
        decorations = "full";
        dimensions = {
          lines = 0; # use recommended size
          columns = 0;
        };
        padding = {
          x = 5;
          y = 5;
        };
        # option_as_alt = "Both"; # supported in v0.12
      };
      keyboard = {
        bindings = [
        #   # macOS quality of life things
        #   {
        #     key = "N";
        #     mods = "Command";
        #     action = "SpawnNewInstance";
        #   }
        #   {
        #     key = "Space";
        #     mods = "Alt";
        #     chars = " ";
        #   }
        #   {
        #     # delete word/line
        #     key = "Back";
        #     mods = "Super";
        #     chars = ''\u0015'';
        #   }
        #   {
        #     # one word left
        #     key = "Left";
        #     mods = "Alt";
        #     chars = ''\x1bb'';
        #   }
        #   {
        #     # one word right
        #     key = "Right";
        #     mods = "Alt";
        #     chars = ''\x1bf'';
        #   }
        #   {
        #     # Home
        #     key = "Left";
        #     mods = "Command";
        #     chars = ''\x1bOH'';
        #     mode = "AppCursor";
        #   }
        #   {
        #     # End
        #     key = "Right";
        #     mods = "Command";
        #     chars = ''\x1bOF'';
        #     mode = "AppCursor";
        #   }
        #   {
        #     # Alt-C for FZF (note that remaining alt keys will still send unicode chars on mac)
        #     key = "C";
        #     mods = "Alt";
        #     chars = ''\x1bc'';
        #   }
        ];
      };
      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
        save_to_clipboard = true;
      };
      font = let
        fontname = "FiraCode Nerd Font Mono";
      in {
        normal = {
          family = fontname;
          style = "Regular";
        };
        bold = {
          family = fontname;
          style = "Bold";
        };
        italic = {
          family = fontname;
          style = "Light";
        };
        size = 12;
      };
      cursor.style = "Block";
      colors = {
        primary = {
          background = "#282a36";
          foreground = "#f8f8f2";
          bright_foreground = "#ffffff";
        };
        cursor = {
          text = "CellBackground";
          cursor = "CellForeground";
        };
        vi_mode_cursor = {
          text = "CellBackground";
          cursor = "CellForeground";
        };
        search = {
          matches = {
            foreground = "#44475a";
            background = "#50fa7b";
          };
          focused_match = {
            foreground = "#44475a";
            background = "#ffb86c";
          };
        };
        footer_bar = {
          background = "#282a36";
          foreground = "#f8f8f2";
        };
        hints = {
          start = {
            foreground = "#282a36";
            background = "#f1fa8c";
          };
          end = {
            foreground = "#f1fa8c";
            background = "#282a36";
          };
        };
        line_indicator = {
          foreground = "None";
          background = "None";
        };
        selection = {
          text = "CellForeground";
          background = "#44475a";
        };
        normal = {
          black = "#21222c";
          red = "#ff5555";
          green = "#50fa7b";
          yellow = "#f1fa8c";
          blue = "#bd93f9";
          magenta = "#ff79c6";
          cyan = "#8be9fd";
          white = "#f8f8f2";
        };
        bright = {
          black = "#6272a4";
          red = "#ff6e6e";
          green = "#69ff94";
          yellow = "#ffffa5";
          blue = "#d6acff";
          magenta = "#ff92df";
          cyan = "#a4ffff";
          white = "#ffffff";
        };
      };
    };
  };
}
