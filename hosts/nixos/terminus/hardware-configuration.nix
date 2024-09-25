# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  # swapDevices = [ { device = "/.swapvol/swapfile"; } ]; # disko takes care of this part

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp5s0";
    networkConfig = {
      Address = "192.168.1.10/24";
      Gateway = "192.168.1.1";
      DNS = " 192.168.1.10";
      # DNS = "1.1.1.1 8.8.8.8";

      # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
      IPv6AcceptRA = true;
    };
    domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
    # make routing on this interface a dependency for network-online.target
    linkConfig.RequiredForOnline = "routable";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
