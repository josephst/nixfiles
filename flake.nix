{
  description = "Nix configuration - Darwin and NixOS";

  inputs = {
    # package repos
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-joseph.url = "github:josephst/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
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

    ghostty.url = "github:ghostty-org/ghostty";

    isd = {
      url = "github:isd-project/isd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    # recyclarr-templates.url = "github:recyclarr/config-templates";
    # recyclarr-templates.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    # secrets
    }@inputs:
    let
      inherit (self) outputs;
      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      homeManagerModules = import ./modules/home-manager;
      helper = import ./lib { inherit inputs outputs; };

      commonHostSpec = {
        username = "joseph";
        userFullName = "Joseph Stahl";
        passwordFile = ./secrets/users/joseph.age;
        tailnet = "taildbd4c.ts.net";
      };
      myConfig = {
        ghToken = ./secrets/ghToken.age;
        keys = import ./keys;
      };

      treefmtEval = helper.forAllSystems (
        system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix
      );

      packages =
        nixpkgs.lib.attrsets.recursiveUpdate
          (helper.forAllSystems (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; }))
          (helper.forLinuxSystems (system: import ./pkgsLinux { pkgs = nixpkgs.legacyPackages.${system}; }));
    in
    {
      inherit
        overlays
        packages
        nixosModules
        darwinModules
        homeManagerModules
        ;

      formatter = helper.forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      # NixOS configuration entrypoint
      nixosConfigurations = {
        terminus = helper.mkNixos {
          hostSpec = commonHostSpec // {
            hostName = "terminus";
            platform = "x86_64-linux";
            isServer = true;
          };
          inherit myConfig;
        };
        orbstack = helper.mkNixos {
          hostSpec = commonHostSpec // {
            hostName = "orbstack";
            platform = "aarch64-linux";
          };
          inherit myConfig;
        };
        iso-gnome = helper.mkNixos {
          hostSpec = commonHostSpec // {
            hostName = "iso-gnome";
            platform = "x86_64-linux";
            userFullName = "Joseph (Nix Installer)";
          };
          inherit myConfig;
        };
      };

      darwinConfigurations = {
        Josephs-MacBook-Air = helper.mkDarwin {
          hostSpec = commonHostSpec // {
            hostName = "Josephs-MacBook-Air";
            platform = "aarch64-darwin";
          };
          inherit myConfig;
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
      devShells = helper.forAllSystems (
        system: import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; }
      );
    };

  # configure nix
  nixConfig = {
    commit-lockfile-summary = "flake: bump inputs";
  };
}
