# modules/darwin/myConfig/default.nix
{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    inputs.determinate.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    inputs.agenix.darwinModules.default
    inputs.nix-index-database.darwinModules.nix-index

    ./brew.nix
    ./networking.nix
    ./user.nix
  ];

  config = {
    environment = {
      systemPackages = [
        # darwin-specific packages
      ];
      variables = {
        SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };

    users.users.root.home = "/var/root";

    fonts = {
      packages = with pkgs; [
        source-code-pro
        font-awesome
        nerd-fonts.fira-code
        nerd-fonts.hack
        nerd-fonts.zed-mono
        iosevka-bin
      ];
    };

    security.pam.services.sudo_local.touchIdAuth = true;

    nix.enable = false; # using Determinate Nix on macOS
    # write nix.custom.conf configuration
    # note: not using module configuration (https://determinate.systems/blog/changelog-determinate-nix-386/) because
    # it does not support "!include file_path" syntax
    environment.etc."nix/nix.custom.conf".text = config.nix.extraOptions + ''
      extra-substituters = https://nix-community.cachix.org
      extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
    '';

    system = {
      stateVersion = 6;
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
          # Disable automatic capitalization as it's annoying when typing code
          NSAutomaticCapitalizationEnabled = false;

          # Disable smart dashes as they're annoying when typing code
          NSAutomaticDashSubstitutionEnabled = false;

          # Disable automatic period substitution as it's annoying when typing code
          NSAutomaticPeriodSubstitutionEnabled = false;

          # Disable smart quotes as they're annoying when typing code
          NSAutomaticQuoteSubstitutionEnabled = false;

          # Disable auto-correct
          NSAutomaticSpellingCorrectionEnabled = false;
        };
      };
    };
  };
}
