# Settings shared among ALL NixOS and nix-darwin installations
{
  pkgs,
  config,
  lib,
  inputs,
  outputs,
  ...
}:
{
  age.secrets.ghToken = {
    file = ./secrets/ghToken.age;
    mode = "0440";
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".backup-pre-hm";
  };

  nix = {
    extraOptions = ''
      !include ${config.age.secrets.ghToken.path}
    '';
    settings = {
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
  };

  environment = {
    variables = {
      LANG = "en_US.UTF-8";
      # SHELL = "fish";
      EDITOR = lib.getExe pkgs.neovim;
      VISUAL = lib.getExe pkgs.neovim;
    };
    systemPackages = with pkgs; [
      agenix
      bashInteractive
      binutils
      coreutils
      curl
      deploy-rs.deploy-rs
      file
      findutils
      fish
      gawk
      git
      gnugrep
      gnused
      gnutar
      gnutls
      home-manager
      mkpasswd
      ncurses
      neovim
      openssh
      rclone
      vim
      wezterm.terminfo
      wget
      zsh
    ];
  };

  # programs.(fish|zsh).enable must be defined here *and* in home-manager section
  # otherwise, nix won't be added to path in fish shell
  programs = {
    bash.enable = true;
    fish = {
      enable = true;
      useBabelfish = true;
    };
    nix-index.enable = true;
    zsh.enable = true;
    ssh.knownHosts = {
      "github.com".hostNames = [ "github.com" ];
      "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

      "gitlab.com".hostNames = [ "gitlab.com" ];
      "gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

      "git.sr.ht".hostNames = [ "git.sr.ht" ];
      "git.sr.ht".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    };
  };
}
