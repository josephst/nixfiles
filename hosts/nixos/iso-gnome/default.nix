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

  system.stateVersion = "25.11";
  home-manager.users.${config.hostSpec.username}.home.stateVersion = "26.05";

}
