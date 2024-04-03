{
  disko.devices = {
    disk = {
      proxmox_vm = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "500MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            nixos = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "2G";
                    };
                  };
                };
              };
            };
          };
        };
      };

      # note: disko only supports single-drive BTRFS arrays,
      # so after manual partitioning of second drive, run
      # `btrfs balance start -v convert=raid1,soft /storage`
      # optionally with `--background`
      # `soft` means not to re-convert chunks that already have desired profile
      storage1 = {
        type = "disk";
        device = "";
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
                    mountOptions = [ "compress=zstd" "noatime" ];
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
                    mountOptions = [ "compress=zstd" "noatime" ];
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
