{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../common
    ../../common

    ./hardware-configuration.nix
    ./disko.nix
    ./networking.nix
    ./services

    inputs.copyparty.nixosModules.default
  ];

  # TODO: figure out why determinate nix keeps being built from source, instead of using binary cache
  # determinate.enable = false;
  determinate.enable = true;

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
      extraUpFlags = [ "--advertise-tags=tag:server" ];
      extraSetFlags = [ "--advertise-exit-node" ];
      useRoutingFeatures = "both";
    };
  };
}
