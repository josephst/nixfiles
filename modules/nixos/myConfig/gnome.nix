{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myConfig.gnome;
in
{
  options.myConfig.gnome = {
    enable = lib.mkEnableOption "gnome";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages =
        [
          pkgs.firefox
          pkgs.wl-clipboard
          pkgs.gnomeExtensions.appindicator
          pkgs.gnomeExtensions.gsconnect
          inputs.ghostty.packages.${pkgs.system}.default # ghostty terminal
        ]
        ++ lib.optionals (builtins.elem config.nixpkgs.hostPlatform pkgs.spotify.meta.platforms) [
          pkgs.spotify
        ];
      gnome.excludePackages = with pkgs; [
        cheese # webcam tool
        epiphany # web browser
        geary # email reader
        evince # document viewer
        totem # video player
        gnome-console
      ];
    };

    services = {
      dbus.enable = true;
      xserver = {
        enable = true;
        displayManager.gdm = {
          enable = true;
        };
        desktopManager.gnome.enable = true;
      };
      usbmuxd.enable = true;
      udev.packages = [ pkgs.gnome-settings-daemon ];
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };
      pulseaudio.enable = false;
    };

    security.rtkit.enable = true;
  };
}
