# Settings shared among ALL NixOS and nix-darwin installations
{ pkgs
, config
, lib
, inputs
, outputs
, ...
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
  };

  environment = {
    shells = [
      pkgs.bashInteractive
      pkgs.fish
      pkgs.zsh
    ];
    variables = {
      LANG = "en_US.UTF-8";
      EDITOR = lib.getExe pkgs.neovim;
      VISUAL = lib.getExe pkgs.neovim;
    };
    systemPackages = with pkgs; [
      agenix
      bashInteractive
      binutils
      bottom
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
      helix
      home-manager
      mkpasswd
      nix
      ncurses
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
