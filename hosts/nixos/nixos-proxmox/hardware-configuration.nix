# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "uhci_hcd"
      "ehci_pci"
      "ahci"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];
    initrd.kernelModules = [ ];

    # from https://nixos.wiki/wiki/Remote_disk_unlocking
    initrd.network = {
      enable = true;
      # To prevent ssh clients from freaking out because a different host key is used,
      # a different port for ssh is useful (assuming the same host has also a regular sshd running)
      port = 2222;
      # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
      # the keys are copied to initrd from the path specified; multiple keys can be set
      # you can generate any number of host keys using
      # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
      hostKeys = [ /etc/secrets/initrd/ssh_host_rsa_key ];
      # public ssh key used for login
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph"
      ];
      postCommands = ''
        # Import all pools
        zpool import -a
        # Add the load-key command to the .profile
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  # root file systems managed by disko

  # zfs file systems managed here
  fileSystems."/mnt/storage" = {
    device = "zpool/root";
    fsType = "zfs";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s18.useDHCP = lib.mkDefault true;

  # configured by cloud-init
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp6s18";
    networkConfig = {
      Address = "192.168.1.10/24";
      Gateway = "192.168.1.1";
      DNS = "1.1.1.1";

      # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
      IPv6AcceptRA = true;
    };
    domains = [ "josephstahl.com" ]; # look up ie nixos.josephstahl.com on the local DNS server
    # make routing on this interface a dependency for network-online.target
    linkConfig.RequiredForOnline = "routable";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
