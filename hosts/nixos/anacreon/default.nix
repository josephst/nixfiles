{
  inputs,
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

  services = {
    openssh.openFirewall = false;
    qemuGuest.enable = true;
    tailscale = {
      extraSetFlags = [ "--advertise-exit-node" ];
      useRoutingFeatures = "both";
    };
  };
}
