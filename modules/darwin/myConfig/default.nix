{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.myConfig;
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.agenix.darwinModules.default
    inputs.nix-index-database.darwinModules.nix-index

    ./networking.nix
    ./user.nix
  ];

  options.myConfig = with lib; {
    nix.substituters = mkOption {
      type = types.listOf types.str;
      # TODO: populate with well-known substituters
      default = [ ];
    };
    platform = mkOption {
      type = types.str;
      default = "aarch64-darwin";
    };
    stateVersion = mkOption {
      type = types.int;
      default = 4;
    };
    tailnet = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    keys = lib.mkOption {
      # TODO: eventually move this to a submodule that can check the attributes
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "SSH keys for users on this system";
    };
    ghToken = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = {
    age = {
      secrets.ghToken = {
        file = cfg.ghToken;
        mode = "0440";
      };
    };
    environment = {
      systemPackages = [
        pkgs.agenix
        pkgs.git
        pkgs.nix-output-monitor
        pkgs.nvd
      ];
      variables = {
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
        SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
    };

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

    nix = {
      gc = {
        automatic = true;
      };
      settings = {
        warn-dirty = false;
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "@admin" ];
      };
      extraOptions = lib.optionalString (config.age.secrets ? "ghToken") ''
        !include ${config.age.secrets.ghToken.path}
      '';
    };

    nixpkgs = {
      hostPlatform = cfg.platform;
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
      };
    };

    programs = {
      fish = {
        enable = true;
        # TODO: is this next line still necessary?
        loginShellInit = "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin";
      };
      nix-index-database.comma.enable = true;
    };

    system = {
      inherit (cfg) stateVersion;
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
  };
}
