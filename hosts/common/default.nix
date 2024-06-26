{
  pkgs,
  config,
  lib,
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

  nix = {
    package = pkgs.nixVersions.latest;
    # registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      auto-optimise-store = true;
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
    };
    extraOptions = ''
      extra-nix-path = nixpkgs=flake:nixpkgs
      !include ${config.age.secrets.ghToken.path}
    '';
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
