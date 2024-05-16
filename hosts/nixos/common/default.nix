{ pkgs, lib, ... }:
{
  imports = [ ./secrets.nix ];

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  environment = {
    # NixOS specific (shared with Darin = goes in ../../common/default.nix)
    systemPackages = with pkgs; [
      cifs-utils
      tailscale
    ];
  };

  programs = {
    ssh = {
      startAgent = true;
    };
    nix-ld = {
      enable = true; # necessary for VSCode Server support
    };
  };

  services = {
    openssh.enable = lib.mkDefault true;
    resolved.enable = lib.mkDefault true; # mkDefault lets it be overridden
  };

  security.pam.sshAgentAuth.enable = true; # enable password-less sudo (using SSH keys)
  security.pam.services.sudo.sshAgentAuth = true;
}
