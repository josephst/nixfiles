{
  description = "Nix configuration - Darwin and NixOS";

  inputs = {
    # package repos
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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

    ghostty.url = "github:ghostty-org/ghostty";

    isd.url = "github:isd-project/isd";

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    { self
    , nixpkgs
    , treefmt-nix
    , ...
      # secrets
    }@inputs:
    let
      inherit (self) outputs;
      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
      helper = import ./lib { inherit inputs outputs; };

      # settings for all machines this flake manages
      commonConfig = {
        tailnet = "taildbd4c.ts.net";
        ghToken = ./secrets/ghToken.age;
        keys = import ./keys;
        user = {
          username = "joseph";
          passwordFile = ./secrets/users/joseph.age;
        };
      };

      treefmtEval = helper.forAllSystems (
        system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix
      );
    in
    {
      inherit overlays nixosModules homeManagerModules;
      packages = nixpkgs.lib.attrsets.recursiveUpdate
        (helper.forAllSystems (
          system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; }
        ))
        (helper.forLinuxSystems (system: import ./pkgsLinux { pkgs = nixpkgs.legacyPackages.${system}; }));
      formatter = helper.forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      # NixOS configuration entrypoint
      nixosConfigurations = {
        terminus = helper.mkNixos {
          hostname = "terminus";
          platform = "x86_64-linux";
          inherit commonConfig;
        };
        orbstack = helper.mkNixos {
          hostname = "orbstack";
          platform = "aarch64-linux";
          inherit commonConfig;
        };
        vmware = helper.mkNixos {
          hostname = "vmware";
          platform = "aarch64-linux";
          inherit commonConfig;
        };
      };

      darwinConfigurations = {
        Josephs-MacBook-Air = helper.mkDarwin {
          hostname = "Josephs-MacBook-Air";
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

      # `nix develop`
      devShells = helper.forAllSystems (system: import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; });
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
