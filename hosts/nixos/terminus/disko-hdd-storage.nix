{
  disko.devices = {
    disk = {
      # note: disko only supports single-drive BTRFS arrays,
      # so add second drive with `btrfs device add /dev/disk/by-id/XXXXXXXX /storage`,
      # then run `btrfs balance start -v convert=raid1,soft /storage`
      # optionally with `--background`
      # `soft` means not to re-convert chunks that already have desired profile
      storage1 = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "/storage" = {
                    mountpoint = "/storage";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/storage/restic" = {
                    mountpoint = "/storage/restic";
                    mountOptions = [ "noatime" ]; # already compressed & encrypted data
                  };
                  "/storage/media" = {
                    mountpoint = "/storage/media";
                    mountOptions = [ "noatime" ];
                  };
                  "/storage/homes" = {
                    mountpoint = "/storage/homes";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
