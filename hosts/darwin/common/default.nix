# system-wide nix config (ie NOT home-manager stuff)
{ inputs, pkgs, ... }:
{
  imports = [ ./secrets.nix ];

  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    systemPackages = with pkgs; [ lima ];
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
    fonts = with pkgs; [
      source-code-pro
      font-awesome
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Hack"
        ];
      })
    ];
  };
}
