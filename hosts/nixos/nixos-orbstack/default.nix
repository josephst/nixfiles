# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ modulesPath, ... }:
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

  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostName = "nixos-orbstack"; # Define your hostname.
    domain = "josephstahl.com";
    firewall.enable = false;
    # networkmanager.enable = true; # Easiest to use and most distros use this by default.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    dhcpcd.enable = false;
    useHostResolvConf = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };
  # systemd.services.NetworkManager-wait-online.enable = false; # causes problems with tailscale
  # systemd.network.wait-online.anyInterface = true;

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Extra certificates from OrbStack.
  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
MIICDTCCAbOgAwIBAgIRAIx8L/EVLqT9+FXXGRvPCOUwCgYIKoZIzj0EAwIwZjEd
MBsGA1UEChMUT3JiU3RhY2sgRGV2ZWxvcG1lbnQxHjAcBgNVBAsMFUNvbnRhaW5l
cnMgJiBTZXJ2aWNlczElMCMGA1UEAxMcT3JiU3RhY2sgRGV2ZWxvcG1lbnQgUm9v
dCBDQTAeFw0yMzEyMDExNDI3NDVaFw0zMzEyMDExNDI3NDVaMGYxHTAbBgNVBAoT
FE9yYlN0YWNrIERldmVsb3BtZW50MR4wHAYDVQQLDBVDb250YWluZXJzICYgU2Vy
dmljZXMxJTAjBgNVBAMTHE9yYlN0YWNrIERldmVsb3BtZW50IFJvb3QgQ0EwWTAT
BgcqhkjOPQIBBggqhkjOPQMBBwNCAAQhLOwTaCy3xSZDDoonUmcoHaAdN1Djv3DH
+N4CnsnD+B1YNbsRvFtM1vSWHLols518Nqq5BPj49cvWIojzeYi4o0IwQDAOBgNV
HQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU+BXrlxTU0iH2
sx8YKBcO3WY7becwCgYIKoZIzj0EAwIDSAAwRQIgP/eP6bwufy74jj8voObLdvXv
yRXVDzRsigth9mQfDU4CIQDrlqvrQsl23gNyCMjfSvDwiB/zaKT5gsrJn6C/9mFT
BQ==
-----END CERTIFICATE-----

    ''
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?
}
