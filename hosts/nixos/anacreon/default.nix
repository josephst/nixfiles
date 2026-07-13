{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../common
    ../common/roles/server.nix
    ../../common

    ./hardware-configuration.nix
    ./disko.nix
    ./networking.nix
    ./services

    ../../../modules/nixos/backrest.nix
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

  system.stateVersion = "25.11";
  home-manager.users.${config.hostSpec.username}.home.stateVersion = "26.05";

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
