# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  modulesPath,
  config,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualization/proxmox-lxc.nix")
  ];

  system.stateVersion = "24.05";
}
