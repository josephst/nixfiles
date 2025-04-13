{ lib, config, ... }:
let
  inherit (config.homebrew) brewPrefix;
in
{
  # Install homebrew if it is not installed
  system.activationScripts.homebrew.text = lib.mkIf config.homebrew.enable (
    lib.mkBefore ''
      if [[ ! -f "${config.homebrew.brewPrefix}/brew" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    ''
  );

  homebrew = {
    enable = true;
    global = {
      # only update with `brew update` (or `just update`)
      autoUpdate = false;
    };
    # Don't quarantine apps installed by homebrew with gatekeeper
    caskArgs.no_quarantine = lib.mkDefault true;
    onActivation = {
      autoUpdate = false;
      upgrade = false; # manually update with 'brew update' and 'brew upgrade'

      # Declarative package management by removing all homebrew packages,
      # not declared in darwin-nix configuration
      cleanup = lib.mkDefault "uninstall";
    };

    taps = [ ];

    brews = [
      "mas"
    ];

    casks = [
      # dev tools
      "1password-cli"
      "1password"
      "cyberduck"
      "ghostty"
      "git-credential-manager"
      "iterm2"
      "notion"
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
      "netnewswire"
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
