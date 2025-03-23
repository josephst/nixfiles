# modified from https://github.com/wimpysworld/nix-config (MIT)
{ inputs
, outputs
, stateVersion
, ...
}:
{
  # Helper function for generating NixOS configs
  mkNixos =
    { hostname
    , platform ? "x86_64-linux"
    ,
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      tailNet = "taildbd4c.ts.net";
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          platform
          stateVersion
          isISO
          tailNet
          ;
      };
      # If the hostname starts with "iso-", generate an ISO image
      modules =
        let
          cd-dvd = inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in
        builtins.attrValues outputs.nixosModules ++ [
          ../hosts/nixos/${hostname}
          { myConfig.hostname = hostname; }
        ] ++ inputs.nixpkgs.lib.optionals isISO [ cd-dvd ];
    };

  mkDarwin =
    { hostname
    , platform ? "aarch64-darwin"
    ,
    }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          platform
          stateVersion
          ;
      };
      modules = [ ../hosts/darwin/${hostname} ];
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
