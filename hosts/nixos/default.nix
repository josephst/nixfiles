# This file holds config used on all NixOS hosts
{ inputs
, outputs
, pkgs
, lib
, ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.srvos.nixosModules.common
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    inputs.srvos.nixosModules.mixins-terminfo
    ../common/default.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  services = {
    resolved = {
      enable = lib.mkDefault true;
      dnsovertls = "opportunistic";
    };
  };

  hardware.enableRedistributableFirmware = true;

  # always install these for all users on nixos systems
  environment.systemPackages = [
    # most are in ../common/default.nix
    pkgs.htop
    pkgs.nh

    # hardware
    pkgs.lshw
    pkgs.usbutils
    pkgs.pciutils
    pkgs.smartmontools
  ];

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/release-notes/rl-2411.section.md
  systemd.enableStrictShellChecks = false; # TODO: broken because of linger-users script
}
