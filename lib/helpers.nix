# modified from https://github.com/wimpysworld/nix-config (MIT)
{ inputs
, outputs
, ...
}:
let
in
{
  # Helper function for generating NixOS configs
  mkNixos =
    { hostname
    , platform ? "x86_64-linux"
    , commonConfig ? {}
    ,
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      myConfig = {
        inherit platform;
        networking.hostname = hostname;
        keys = import ../keys;
        user = {
          username = "joseph";
          passwordFile = ../secrets/users/joseph.age;
        };
        ghToken = commonConfig.ghToken;
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      # If the hostname starts with "iso-", generate an ISO image
      modules =
        let
          cd-dvd = inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in
        (builtins.attrValues outputs.nixosModules) ++ [
          ../hosts/nixos/${hostname}
          { inherit myConfig; }
        ] ++ inputs.nixpkgs.lib.optionals isISO [ cd-dvd ];
    };

  mkDarwin =
    { hostname
    , platform ? "aarch64-darwin"
    , commonConfig ? {}
    ,
    }:
    let
      myConfig = {
        inherit platform;
        networking.hostname = hostname;
        keys = import ../keys;
        user = {
          username = "joseph";
          passwordFile = ../secrets/users/joseph.age;
        };
        ghToken = commonConfig.ghToken;
      };
    in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        { inherit myConfig;}
        ../hosts/darwin/${hostname}
      ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    # "x86_64-darwin"
  ];

  forLinuxSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
