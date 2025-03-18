{
  # config,
  desktop
, # isInstall,
  lib
, pkgs
, ...
}: {
  imports = [
    ./apps
    ./features
  ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop};

  boot.plymouth.enable = lib.mkDefault true;

  services = {
    dbus.enable = true;
    usbmuxd.enable = true;
    xserver = {
      desktopManager.xterm.enable = false;
      excludePackages = [ pkgs.xterm ];
    };
  };

  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    # polkitPolicyOwners = [ "yourUsernameHere" ];
  };
}
