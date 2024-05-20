{
  description = "Nix configuration - Darwin and NixOS";

  inputs = {
    # package repos
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
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

    # attic
    # attic = {
    #   url = "github:zhaofengli/attic";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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

    # llama.cpp
    llama-cpp = {
      url = "github:ggerganov/llama.cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      agenix,
      disko,
      ...
    # secrets
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        # "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      overlays = import ./overlays { inherit inputs; };

      legacyPackages = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );
    in
    {
      inherit overlays;

      packages = forAllSystems (
        system:
        let
          pkgs = legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; }
      );

      darwinConfigurations = {
        Josephs-MacBook-Air = darwin.lib.darwinSystem {
          # darwin-rebuild switch --flake .
          system = "aarch64-darwin";
          pkgs = legacyPackages.aarch64-darwin;
          modules = [
            home-manager.darwinModules.home-manager
            agenix.darwinModules.default
            ./modules/darwin

            ./hosts/common
            ./hosts/darwin/common
            ./hosts/darwin/josephs-air

            ./users/joseph.nix
          ];
          specialArgs = inputs;
        };
      };

      nixosConfigurations = {
        nixos-orbstack = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          pkgs = legacyPackages.aarch64-linux;
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            ./modules/nixos

            ./hosts/common # nixOS and Darwin
            ./hosts/nixos/common # nixOS-specific
            ./hosts/nixos/nixos-orbstack # host-specific

            ./users/joseph.nix
            ./users/root.nix
          ];
          specialArgs = inputs;
        };

        nixos = nixpkgs.lib.nixosSystem {
          # nixos-rebuild switch --flake .
          system = "x86_64-linux";
          pkgs = legacyPackages.x86_64-linux;
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            disko.nixosModules.disko
            ./modules/nixos

            ./hosts/common # nixOS and Darwin
            ./hosts/nixos/common # nixOS-specific
            ./hosts/nixos/nixos-proxmox # host-specific

            ./users/joseph.nix
            ./users/root.nix
          ];
          specialArgs = inputs;
        };

        # UTM virtual machine
        anacreon = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          pkgs = legacyPackages.aarch64-linux;
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            disko.nixosModules.disko
            ./modules/nixos

            ./hosts/common
            ./hosts/nixos/common
            ./hosts/nixos/anacreon

            ./users/joseph.nix
            ./users/root.nix
          ];
          specialArgs = inputs;
        };
      };

      deploy.nodes = {
        nixos = {
          # override hostname with `nix run github:serokell/deploy-rs .#nixos -- --hostname 192.168.1.10`
          # (if DNS not yet set up/ working)
          hostname = "nixos.josephstahl.com";
          profiles.system = {
            path = legacyPackages.x86_64-linux.deploy-rs.lib.activate.nixos self.nixosConfigurations.nixos;
            sshUser = "root";
            magicRollback = true;
            remoteBuild = true; # since it may be cross-platform
          };
        };
      };

      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      # `nix develop`
      devShells = forAllSystems (
        system:
        let
          pkgs = legacyPackages.${system};
        in
        import ./shell.nix { inherit pkgs; }
      );

      # `nix fmt`
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };

  # configure nix
  nixConfig = {
    commit-lockfile-summary = "flake: bump inputs";
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
