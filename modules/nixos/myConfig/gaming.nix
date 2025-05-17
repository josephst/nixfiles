{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myConfig.gaming;
in
{
  options.myConfig.gaming = {
    enable = lib.mkEnableOption "gaming";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.lutris.override {
        extraLibraries =
          p: with p; [
            libadwaita
            gtk4
          ];
      })
      pkgs.protonup-ng
      pkgs.wine
    ];
    programs = {
      steam = {
        enable = true;
      };
      gamemode.enable = true;
      # sunshine.enable = true;
      corectrl = {
        enable = true;
      };
    };
  };
}
