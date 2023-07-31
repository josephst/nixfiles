# system-wide nix config (ie NOT home-manager stuff)
{
  inputs,
  pkgs,
  ...
}: let
  user = "joseph";
in {
  users.users.${user}.home = "/Users/${user}";

  nix = {
    gc = {
      automatic = true;
      interval = {
        Day = 7;
      };
      options = "--delete-older-than 7d";
    };
  };

  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        colima
        # lima
        
        ;
    };
  };

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    stateVersion = 4; # nix-darwin stateVersion
    defaults = {
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
      };
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts =
      lib.attrValues {
        inherit
          (pkgs)
          source-code-pro
          font-awesome
          ;
      }
      ++ [
        (pkgs.nerdfonts.override {
          fonts = [
            "FiraCode"
            "Hack"
          ];
        })
      ];
  };
}
