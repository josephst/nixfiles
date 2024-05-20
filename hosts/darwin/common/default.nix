# system-wide nix config (ie NOT home-manager stuff)
{ pkgs, ... }:
{
  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    systemPackages = [];
  };

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  nix.gc = {
    user = "root";
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 2;
      Minute = 0;
    };
  };

  system = {
    stateVersion = 4; # nix-darwin stateVersion
    defaults = {
      # Don't show recent applications in the dock
      dock.show-recents = false;

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = true;
        _FXShowPosixPathInTitle = true;
      };
      NSGlobalDomain = {
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.sound.beep.volume" = 0.0;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        # Expand save panel by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Expand print panel by default
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;

        # Save to disk (not to iCloud) by default
        NSDocumentSaveNewDocumentsToCloud = true;

        # Disable automatic termination of inactive apps
        NSDisableAutomaticTermination = true;

        # KEYBOARD
        # Disable automatic capitalization as it’s annoying when typing code
        NSAutomaticCapitalizationEnabled = false;

        # Disable smart dashes as they’re annoying when typing code
        NSAutomaticDashSubstitutionEnabled = false;

        # Disable automatic period substitution as it’s annoying when typing code
        NSAutomaticPeriodSubstitutionEnabled = false;

        # Disable smart quotes as they’re annoying when typing code
        NSAutomaticQuoteSubstitutionEnabled = false;

        # Disable auto-correct
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      source-code-pro
      font-awesome
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Hack"
        ];
      })
      iosevka-bin
    ];
  };
}
