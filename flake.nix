{
  description = "Nix configuration - Darwin and NixOS";

  inputs = {
    # package repos
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deploy-rs
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zig nightly overlay
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    darwin,
    agenix,
    deploy-rs,
    zig,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    overlays = import ./overlays {inherit inputs;};

    legacyPackages = forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
    );

    nixosModules = import ./modules/nixos;
  in {
    overlays = overlays;

    packages = forAllSystems (
      system: let
        pkgs = legacyPackages.${system};
      in
        import ./pkgs {inherit pkgs inputs;}
    );

    darwinConfigurations = {
      josephs-air = darwin.lib.darwinSystem {
        # darwin-rebuild switch --flake .
        system = "aarch64-darwin";
        pkgs = legacyPackages.aarch64-darwin;
        modules = [
          home-manager.darwinModules.home-manager
          agenix.nixosModules.default
          ./hosts/darwin/josephs-air
        ];
        specialArgs = {inherit inputs;};
      };
    };

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        # nixos-rebuild switch --flake .
        system = "x86_64-linux";
        pkgs = legacyPackages.x86_64-linux;
        modules =
          [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            ./hosts/nixos/nixos-proxmox
          ]
          ++ (builtins.attrValues nixosModules);
        specialArgs = {inherit inputs;};
      };
    };

    deploy.nodes = {
      nixos = {
        hostname = "nixos.josephstahl.com";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos;
          sshUser = "joseph";
          user = "root";
          sshOpts = ["-t"];
          magicRollback = false; # breaks remote sudo
          remoteBuild = true; # since it may be cross-platform
        };
      };
    };

    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    devShells = forAllSystems (
      system: let
        pkgs = legacyPackages.${system};
      in
        import ./shell.nix {inherit pkgs;}
    );

    formatter = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
  };

  # configure nix
  nixConfig = {
    commit-lockfile-summary = "flake: bump inputs";
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };
}
