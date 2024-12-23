{
  description = "Nix configuration - Darwin and NixOS";

  inputs = {
    # package repos
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
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

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
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
      url = "github:ggerganov/llama.cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    { self
    , nixpkgs
    , darwin
    , treefmt-nix
    , ...
      # secrets
    }@inputs:
    let
      inherit (self) outputs;
      supportedSystems = [
        "x86_64-linux"
        # "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkNixos =
        modules:
        nixpkgs.lib.nixosSystem {
          modules = modules ++ [
            ./hosts/nixos
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };

      treefmtEval = forAllSystems (system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix);
    in
    {
      overlays = import ./overlays { inherit inputs; };
      packages = forAllSystems (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      nixosConfigurations = {
        terminus = mkNixos [
          ./hosts/nixos/terminus
          ./users/joseph.nix
        ];
        nixos-orbstack = mkNixos [
          ./hosts/nixos/orbstack
          ./users/joseph.nix
        ];
      };

      darwinConfigurations = {
        Josephs-MacBook-Air = darwin.lib.darwinSystem {
          # darwin-rebuild switch --flake .
          modules = [
            ./hosts/darwin/default.nix
            ./hosts/darwin/josephs-macbook-air
            ./users/joseph.nix
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };

      deploy.nodes = {
        terminus = {
          # override hostname with `nix run github:serokell/deploy-rs .#terminus -- --hostname 192.168.1.10`
          # (if DNS not yet set up/ working)
          hostname = "terminus.josephstahl.com";
          profiles.system = {
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.terminus;
            sshUser = "joseph";
            user = "root";
            magicRollback = true;
            remoteBuild = true; # since it may be cross-platform
          };
        };
      };

      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      # `nix develop`
      devShells = forAllSystems (system: import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; });
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
