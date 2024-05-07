{lib, config, ...}:
let
  brewPrefix = config.homebrew.brewPrefix;
in
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
      "1password/tap"
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
    ];

    casks = [
      # dev tools
      "1password-cli"
      "1password"
      "alacritty"
      "cyberduck"
      "git-credential-manager"
      "iterm2"
      "orbstack"
      "utm"
      "visual-studio-code"
      "warp"

      # utility
      "appcleaner"
      "logi-options-plus"

      # media
      "digikam"
      "spotify"
      "steam"
      "vlc"

      # communication
      "microsoft-teams"
      "zoom"

      # AI
      "ollama"

      # productivity
      "raycast"
      "rectangle"
      "stats"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "Todoist" = 585829637;
      "Tailscale" = 1475387142;
      "Fantastical" = 975937182;
      # "Microsoft 365" = 1450038993;
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

  environment.loginShellInit = lib.mkIf (config.homebrew.enable) ''
    eval $(${brewPrefix}/brew shellenv)
  '';
}
