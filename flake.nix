{
  description = "Nix configuration - Darwin and NixOS";

  inputs = {
    # package repos
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:josephst/nixpkgs/whois-implicit-functions";
    # nixpkgs-unstable.follows = "nixpkgs";

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

    # llama.cpp
    llama-cpp = {
      # url = "github:ggerganov/llama.cpp";
      url = "github:josephst/llama.cpp/nix-darwin-xcrun";
    };

    # disko
    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      darwin,
      agenix,
      deploy-rs,
      zig,
      llama-cpp,
    # disko,
    # secrets
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
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

      nixosModules = import ./modules/nixos;
    in
    {
      inherit overlays;

      packages = forAllSystems (
        system:
        let
          pkgs = legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs inputs; }
      );

      darwinConfigurations = {
        Josephs-MacBook-Air = darwin.lib.darwinSystem {
          # darwin-rebuild switch --flake .
          system = "aarch64-darwin";
          pkgs = legacyPackages.aarch64-darwin;
          modules = [
            home-manager.darwinModules.home-manager
            agenix.darwinModules.default
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
            ./hosts/common # nixOS and Darwin
            ./hosts/nixos/common # nixOS-specific
            ./hosts/nixos/nixos-orbstack # host-specific
            ./users/joseph.nix
            ./users/root.nix
          ] ++ (builtins.attrValues nixosModules);
          specialArgs = inputs;
        };

        nixos = nixpkgs.lib.nixosSystem {
          # nixos-rebuild switch --flake .
          system = "x86_64-linux";
          pkgs = legacyPackages.x86_64-linux;
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            ./hosts/common # nixOS and Darwin
            ./hosts/nixos/common # nixOS-specific
            ./hosts/nixos/nixos-proxmox # host-specific
            ./users/joseph.nix
            ./users/root.nix
          ] ++ (builtins.attrValues nixosModules);
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
