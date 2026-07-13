{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.determinate.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default

    ./networking.nix
  ];

  config = {
    time.timeZone = lib.mkDefault "America/New_York";

    # user configuration
    users.mutableUsers = lib.mkDefault false;
    security = {
      # use ssh keys instead of password
      pam.sshAgentAuth.enable = true;
    };

    services = {
      openssh = {
        enable = lib.mkDefault true;
        openFirewall = lib.mkDefault true;
        settings = {
          PasswordAuthentication = lib.mkDefault false;
          # Log in as the normal user and elevate with sudo instead.
          PermitRootLogin = "no";

          # Automatically remove stale sockets
          StreamLocalBindUnlink = "yes";
          # Allow forwarding ports to everywhere
          GatewayPorts = "clientspecified";
        };
      };
    };

    environment = {
      systemPackages = [
        # nixos-specific packages
        inputs.isd.packages.${pkgs.stdenv.hostPlatform.system}.default # interactive systemd
        pkgs.bubblewrap # needed for codex-cli sandboxing
        pkgs.dnsutils
        pkgs.ghostty.terminfo
        pkgs.htop
        pkgs.wezterm.terminfo
        pkgs.rsync
        pkgs.tmux

        # shells
        pkgs.bashInteractive
        pkgs.fish
        pkgs.nushell
        pkgs.zsh
      ];
    };

    programs = {
      _1password.enable = true;
      nh = {
        enable = true;
      };
      nix-ld.enable = true;
    };

  };
}
