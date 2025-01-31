# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, inputs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
  ];

  myconfig.gui.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "vmware";

  virtualisation.vmware.guest.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
