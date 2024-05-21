# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    ## Orbstack
    # default LXD configuration
    "${modulesPath}/virtualisation/lxc-container.nix"
    # container-specific autogenerated configuration
    ./lxd.nix
    ./orbstack.nix
  ];

  age.identityPaths = [
    # since openssh isn't enabled on Orbstack, need to generate these with `sudo ssh-keygen -A` first
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  networking = {
    hostName = "nixos-orbstack"; # Define your hostname.
    domain = "josephstahl.com";
    firewall.enable = false;
    # networkmanager.enable = true; # Easiest to use and most distros use this by default.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };
  # systemd.services.NetworkManager-wait-online.enable = false; # causes problems with tailscale
  # systemd.network.wait-online.anyInterface = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # As this is intended as a stadalone image, undo some of the minimal profile stuff
  environment.noXlibs = false;
  documentation.enable = true;
  documentation.nixos.enable = true;
  services.logrotate.enable = true;
}
