# IMPORTANT: This is used by NixOS and nix-darwin so options must exist in both!
{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./nix-settings.nix
    ./ssh-infrastructure.nix
    ./home-manager.nix
    ./users.nix
  ];

  config = {
    nixpkgs = {
      hostPlatform = config.hostSpec.platform;
      overlays = [
        outputs.overlays.default
        inputs.agenix.overlays.default
        inputs.zig.overlays.default
        inputs.copyparty.overlays.default
      ];
      config = {
        allowUnfree = true;
      };
    };

    programs = {
      # programs available on both nixOS and nix-darwin
      fish = {
        enable = true;
        useBabelfish = true;
        shellAliases = {
          nano = "micro";
          fnix = "nix-shell --run fish"; # use as `fnix -p go` to have a fish shell with go in it
        };
      };
      nix-index-database.comma.enable = true; # from https://github.com/nix-community/nix-index-database

      # SSH configuration is now handled by ./ssh-infrastructure.nix
    };

    environment = {
      variables = {
        EDITOR = "hx";
        SYSTEMD_EDITOR = "hx";
        VISUAL = "hx";
      };
      systemPackages = [
        pkgs.deploy-rs
        pkgs.agenix
        pkgs.helix
        pkgs.micro
        pkgs.git
        pkgs.nix-output-monitor
        pkgs.nvd
      ];
    };
  };
}
