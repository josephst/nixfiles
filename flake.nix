{
  description = "Nix configuration - Darwin and NixOS";

  inputs = {
    # package repos
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
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

      # Optional but recommended to limit the size of your system closure.
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

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      agenix,
      deploy-rs,
      disko,
      hardware,
      lanzaboote,
      ...
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
          inherit modules;
          specialArgs = {
            inherit inputs outputs;
          };
        };

    in
    {
      overlays = import ./overlays { inherit inputs; };
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # `nix fmt`
      formatter = forAllSystems (system: self.packages.${system}.nixfmt-plus);
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      nixosConfigurations = {
        terminus = mkNixos [ ./hosts/terminus ];
        orbstack = mkNixos [ ./hosts/orbstack ];
      };

      darwinConfigurations = {
        Josephs-MacBook-Air = darwin.lib.darwinSystem {
          # darwin-rebuild switch --flake .
          system = "aarch64-darwin";
          pkgs = outputs.packages.aarch64-darwin;
          modules = [
            home-manager.darwinModules.home-manager
            agenix.darwinModules.default

            ./hosts/common
            ./hosts/darwin/common
            ./hosts/darwin/josephs-air

            ./users/joseph.nix
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };

      # nixosConfigurations = {
      #   nixos-orbstack = nixpkgs.lib.nixosSystem {
      #     system = "aarch64-linux";
      #     pkgs = legacyPackages.aarch64-linux;
      #     modules = [
      #       home-manager.nixosModules.home-manager
      #       agenix.nixosModules.default
      #       ./modules/nixos

      #       ./hosts/common # nixOS and Darwin
      #       ./hosts/nixos/common # nixOS-specific
      #       ./hosts/nixos/nixos-orbstack # host-specific

      #       ./users/joseph.nix
      #       ./users/root.nix
      #     ];
      #     specialArgs = {
      #       inherit inputs;
      #     };
      #   };

        # terminus = nixpkgs.lib.nixosSystem {
        #   # nixos-rebuild switch --flake .
        #   system = "x86_64-linux";
        #   pkgs = legacyPackages.x86_64-linux;
        #   modules = [
        #     home-manager.nixosModules.home-manager
        #     agenix.nixosModules.default
        #     disko.nixosModules.disko
        #     lanzaboote.nixosModules.lanzaboote
        #     ./modules/nixos

        #     ./hosts/common # nixOS and Darwin
        #     ./hosts/nixos/common # nixOS-specific
        #     ./hosts/nixos/terminus # host-specific

        #     ./users/joseph.nix
        #     ./users/root.nix
        #   ];
        #   specialArgs = {
        #     inherit inputs;
        #   };
        # };

        # UTM virtual machine
      #   anacreon = nixpkgs.lib.nixosSystem {
      #     system = "aarch64-linux";
      #     pkgs = legacyPackages.aarch64-linux;
      #     modules = [
      #       home-manager.nixosModules.home-manager
      #       agenix.nixosModules.default
      #       disko.nixosModules.disko
      #       ./modules/nixos

      #       ./hosts/common
      #       ./hosts/nixos/common
      #       ./hosts/nixos/mixins/systemd-boot.nix
      #       ./hosts/nixos/anacreon

      #       ./users/joseph.nix
      #       ./users/root.nix
      #     ];
      #     specialArgs = {
      #       inherit inputs;
      #     };
      #   };
      # };

      # deploy.nodes = {
      #   terminus = {
      #     # override hostname with `nix run github:serokell/deploy-rs .#terminus -- --hostname 192.168.1.10`
      #     # (if DNS not yet set up/ working)
      #     hostname = "terminus.josephstahl.com";
      #     profiles.system = {
      #       path = legacyPackages.x86_64-linux.deploy-rs.lib.activate.nixos self.nixosConfigurations.terminus;
      #       sshUser = "root";
      #       magicRollback = true;
      #       remoteBuild = true; # since it may be cross-platform
      #     };
      #   };
      # };

      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      # `nix develop`
      devShells = forAllSystems (system: import ./shell.nix nixpkgs.legacyPackages.${system});
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
