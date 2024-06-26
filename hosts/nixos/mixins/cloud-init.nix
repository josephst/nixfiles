# https://github.com/nix-community/srvos/blob/main/nixos/mixins/cloud-init.nix
{ lib, config, ... }:
{
  services.cloud-init =
    {
      enable = lib.mkDefault true;
      network.enable = lib.mkDefault true;

      # Never flush the host's SSH keys. See #148. Since we build the images
      # using NixOS, that kind of issue shouldn't happen to us.
      settings.ssh_deletekeys = lib.mkDefault false;
      ## Automatically enable the filesystems that are used
    }
    // (lib.genAttrs
      (
        [
          "btrfs"
          "ext4"
        ]
        ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor lib.version) "23.11") "xfs"
      )
      (fsName: {
        enable = lib.mkDefault (lib.any (fs: fs.fsType == fsName) (lib.attrValues config.fileSystems));
      })
    );

  # better to write all configuration manually
  # https://nixos.wiki/wiki/Systemd-networkd
  # networking.useNetworkd = lib.mkDefault false;
  networking.useDHCP = lib.mkDefault false;

  # Delegate the hostname setting to cloud-init by default
  networking.hostName = lib.mkDefault "";
}
