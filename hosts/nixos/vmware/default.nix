# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ lib,
...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
  ];

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = lib.mkForce "25.05";
  # TODO: inherit stateVersion
}
