# modified from https://github.com/wimpysworld/nix-config (MIT)
{ inputs
, outputs
, stateVersion
, ...
}:
{
  # Helper function for generating NixOS configs
  # TODO: find a way to make hostname part of myConfig nixosModule
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
          hostname
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
        ] ++ inputs.nixpkgs.lib.optionals isISO [ cd-dvd ];
    };

  mkDarwin =
    { hostname
    , platform ? "aarch64-darwin"
    ,
    }:
    let
      isISO = false;
      isInstall = true;
      isLaptop = true;
      isWorkstation = true;
    in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          hostname
          platform
          stateVersion
          isInstall
          isISO
          isLaptop
          isWorkstation
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
