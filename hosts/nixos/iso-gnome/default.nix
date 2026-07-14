{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ../common # nixos common
    ../../common # nixos AND nix-darwin common

    # mixins
    ../common/mixins/gnome.nix
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    "${modulesPath}/installer/cd-dvd/latest-kernel.nix"
  ];

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # The pinned Calamares GNOME module emits a Bash [[ ... ]] expression for
  # QT_QPA_PLATFORM that Babelfish cannot translate. foreign-env sources it
  # correctly and also preserves the X11 path used by XRDP.
  programs.fish.useBabelfish = false;

  system.stateVersion = "25.11";
  home-manager.users.${config.hostSpec.username}.home.stateVersion = "26.05";

}
