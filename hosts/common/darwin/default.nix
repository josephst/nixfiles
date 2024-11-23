# This file is here as a placeholder, it will hold darwin-specific configuration
# shared accross all nix-darwin machines
{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.agenix.darwinModules.default
    ../default.nix
  ] ++ builtins.attrValues outputs.darwinModules;

  environment = {
    shells = [
      pkgs.bashInteractive
      pkgs.fish
      pkgs.zsh
    ];
    systemPackages = [
      # most are in ../common/default.nix
    ];
    systemPath = lib.mkBefore [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];
    variables = {
      SHELL = lib.getExe pkgs.zsh;
      SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };
  };

  fonts = {
    packages = with pkgs; [
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

  homebrew = {
    enable = true;
    global = {
      # only update with `brew update` (or `just update`)
      autoUpdate = false;
    };
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [ "git" ];
  };

  programs.fish.loginShellInit = "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin";

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  nix = {
    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
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
}
