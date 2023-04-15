{
  inputs,
  pkgs,
  config,
  ...
}: let
  authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop"];
in {
  # shared configuration that should be used for ALL NixOS installs

  # use age encryption key in special location (public & private keys created during nixos install)
  age.identityPaths = ["/etc/secrets/initrd/ssh_host_ed25519_key"];

  age.secrets.hashedUserPassword = {
    file = ../../secrets/hashedUserPassword.age;
  };

  users.mutableUsers = false;
  users.users = {
    joseph = {
      isNormalUser = true;
      extraGroups = ["wheel" "media"]; # Enable ‘sudo’ for the user.
      # user's packages managed by home-manager
      packages = builtins.attrValues {
        inherit
          (pkgs)
          ;
      };
      passwordFile = config.age.secrets.hashedUserPassword.path;
      openssh = {
        inherit authorizedKeys;
      };
    };
    root = {
      openssh = {
        inherit authorizedKeys;
      };
    };
  };
  # Create the group for media stuff (plex, sabnzbd, etc)
  users.groups.media = {};

  environment = {
    systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        cifs-utils
        curl
        parted
        tailscale
        vim
        wget
        ;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  programs = {
    nix-ld = {
      enable = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        permitRootLogin = "without-password";
      };
    };
  };
}
