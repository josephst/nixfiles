{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./secrets
    ./nix.nix
    ./trusted-nix-caches.nix
    ./upgrade-diff.nix
    ./well-known-hosts.nix
  ];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    package = pkgs.nixVersions.latest;
    settings = {
      auto-optimise-store = pkgs.stdenv.isLinux; # only optimize on NixOS
      cores = lib.mkDefault 0; # value of 0 = all available cores
      max-jobs = lib.mkDefault "auto";
      trusted-users = [
        "root"
        "@wheel"
        "@staff"
      ];
      warn-dirty = false;
      allowed-users = [ "*" ];
      # enabling sandbox prevents .NET from accessing /usr/bin/codesign
      # and stops binary signing from working
      # sandbox = true; # defaults to true on Linux, false for Darwin
      sandbox = if pkgs.stdenv.isDarwin then "relaxed" else true;
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Opinionated: make flake registry match flake inputs
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    extraOptions = ''
      !include ${config.age.secrets.ghToken.path}
    '';
  } // lib.optionalAttrs (pkgs.stdenv.isLinux) {
    # Opinionated: disable channels
    channel.enable = false;
  } // lib.optionalAttrs (pkgs.stdenv.isDarwin) {
    daemonIOLowPriority = false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment = {
    variables = {
      LANG = "en_US.UTF-8";
      # SHELL = "fish";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      agenix
      bashInteractive
      binutils
      coreutils
      curl
      deploy-rs.deploy-rs
      file
      fish
      git
      mkpasswd
      neovim
      openssh
      rclone
      vim
      wget
      zsh
    ];
  };

  # programs.(fish|zsh).enable must be defined here *and* in home-manager section
  # otherwise, nix won't be added to path in fish shell
  programs = {
    fish = {
      enable = true;
      useBabelfish = true;
    };
    zsh.enable = true;
  };
}
