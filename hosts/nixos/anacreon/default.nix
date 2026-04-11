{
  inputs,
  config,
  lib,
  ...
}:
{
  disabledModules = [
    ../../common/home-manager.nix
  ];

  imports = [
    ../common
    ../../common

    ./hardware-configuration.nix
    ./disko.nix
    ./networking.nix
    ./services

    inputs.copyparty.nixosModules.default
  ];

  age.identityPaths = map (builtins.getAttr "path") config.services.openssh.hostKeys;

  boot.loader = {
    efi.canTouchEfiVariables = lib.mkForce false;
    grub.enable = true;
    systemd-boot.enable = lib.mkForce false;
  };

  services = {
    openssh.openFirewall = false;
    qemuGuest.enable = true;
    tailscale = {
      extraSetFlags = [ "--advertise-exit-node" ];
      useRoutingFeatures = "both";
    };
  };
}
