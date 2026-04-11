_: {
  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "dm_mod"
      "sr_mod"
      "sd_mod"
      "uhci_hcd"
      "virtio_blk"
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];
    initrd.kernelModules = [ ];
    initrd.systemd.enable = true;
    kernelModules = [ ];
    extraModulePackages = [ ];
  };
}
