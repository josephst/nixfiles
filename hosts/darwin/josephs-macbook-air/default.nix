{pkgs, lib, config, inputs, outputs, ...}:
let
  keys = import ../../../keys;
in
{
  # machine-specific config
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.agenix.darwinModules.default
    inputs.nix-index-database.darwinModules.nix-index

    ./brew.nix
  ];

  # TODO: refactor this into a module, similar to nixos module
  users.users.joseph = {
    packages = [ pkgs.home-manager ];
    home = "/Users/joseph";
    openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
  };
  home-manager.users.joseph = import ../../../home;

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

  networking.hostName = "Josephs-MacBook-Air";
  networking.computerName = "Josephs-MacBook-Air";

  nix = {
    gc = {
      automatic = true;
    };
    settings = {
      warn-dirty = false;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@admin" ];
    };
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
    hostPlatform = lib.mkDefault "${pkgs.system}";
  };

  programs = {
    fish = {
      enable = true;
      loginShellInit = "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin";
    };
    nix-index-database.comma.enable = true;
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
      username = "joseph";
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".backup-pre-hm";
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
