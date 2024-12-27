{ lib, config, ... }:
let
  inherit (config.homebrew) brewPrefix;
in
{
  homebrew = {
    taps = [ ];

    casks = [
      # dev tools
      "1password-cli"
      "1password"
      "alacritty"
      # "amethyst"
      "cyberduck"
      "ghostty"
      "git-credential-manager"
      "iterm2"
      "orbstack"
      "utm"
      "visual-studio-code"
      "wezterm"
      "zed"

      # utility
      "appcleaner"
      "logi-options+"

      # media
      # "digikam"
      "iina"
      "shottr"
      "spotify"
      "steam"

      # communication
      "microsoft-teams"
      "zoom"

      # AI
      "ollama"

      # productivity
      "raycast"
      # "rectangle"
      "stats"
      "tailscale"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "Fantastical" = 975937182;
      "1Password for Safari" = 1569813296;
      "Microsoft Word" = 462054704;
      "Microsoft Excel" = 462058435;
      "Microsoft Outlook" = 985367838;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft OneNote" = 784801555;
      "OneDrive" = 823766827;
      "Xcode" = 497799835;
    };
  };

  environment.loginShellInit = lib.mkIf config.homebrew.enable ''
    eval $(${brewPrefix}/brew shellenv)
  '';
}
