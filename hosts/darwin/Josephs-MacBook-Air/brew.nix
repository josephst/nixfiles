{ lib, config, ... }:
let
  inherit (config.homebrew) brewPrefix;
in
{
  homebrew = {
    casks = [
      # dev tools
      "1password-cli"
      "1password"
      "cyberduck"
      "ghostty"
      "git-credential-manager"
      "notion"
      "utm"
      "visual-studio-code"
      "zed"

      # utility
      "appcleaner"
      "logi-options+"

      # media
      "iina"
      "shottr"
      "spotify"
      "steam"

      # communication
      "microsoft-teams"
      "netnewswire"
      "zoom"

      # AI
      "ollama-app"
      "lm-studio"

      # productivity
      "raycast"
      "tailscale-app"
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

  environment.shellInit = lib.mkIf config.homebrew.enable ''
    eval $(${brewPrefix}/brew shellenv)
  '';
}
