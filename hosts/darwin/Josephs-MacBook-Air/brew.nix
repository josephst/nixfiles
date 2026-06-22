_: {
  homebrew = {
    brews = [
      {
        name = "garethgeorge/homebrew-backrest-tap/backrest";
        restart_service = "changed";
        start_service = true;
      }
    ];
    casks = [
      # dev tools
      "1password-cli"
      "1password"
      "cyberduck"
      "ghostty"
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
      "Crouton" = 1461650987;
      "Fantastical" = 975937182;
      "Keynote" = 361285480;
      "Microsoft Word" = 462054704;
      "Microsoft Excel" = 462058435;
      "Microsoft Outlook" = 985367838;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft OneNote" = 784801555;
      "OneDrive" = 823766827;
      "Xcode" = 497799835;

      # safari
      "Raindrop.io" = 1549370672;
      "1Password for Safari" = 1569813296;
      "Wipr 2" = 662217862;
    };
  };
}
