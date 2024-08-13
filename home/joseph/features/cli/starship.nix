_: {
  programs = {
    starship = {
      enable = false;
      settings = {
        line_break = {
          disabled = true;
        };

        # preset: no nerd font
        battery = {
          full_symbol = "• ";
          charging_symbol = "⇡ ";
          discharging_symbol = "⇣ ";
          unknown_symbol = "❓ ";
          empty_symbol = "❗ ";
        };
        erlang = {
          symbol = "ⓔ ";
        };
        nodejs = {
          symbol = "[⬢](bold green) ";
        };
        pulumi = {
          symbol = "🧊 ";
        };
        typst = {
          symbol = "t ";
        };
      };
    };
  };
}
