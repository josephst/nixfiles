{
  config,
  lib,
  pkgs,
  ...
}:
{
  assertions = [
    {
      assertion = config.hostSpec.role == "server";
      message = "hosts/nixos/common/roles/server.nix requires hostSpec.role = \"server\"";
    }
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot = {
    loader.systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = lib.mkOverride 1337 10;
    };
    loader.timeout = lib.mkDefault 3;
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    tmp.useTmpfs = lib.mkDefault true;
  };

  zramSwap.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    lshw
    nvme-cli
    pciutils
    smartmontools
    usbutils
  ];
}
