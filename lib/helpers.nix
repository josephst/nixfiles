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
    , username ? "joseph"
    , desktop ? null
    , platform ? "x86_64-linux"
    ,
    }:
    let
      isISO = builtins.substring 0 4 hostname == "iso-";
      isInstall = !isISO;
      isLaptop = hostname != "terminus";
      isWorkstation = builtins.isString desktop; # enable GUI features
      tailNet = "taildbd4c.ts.net";
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          isInstall
          isISO
          isLaptop
          isWorkstation
          tailNet
          ;
      };
      # If the hostname starts with "iso-", generate an ISO image
      modules =
        let
          cd-dvd =
            if (desktop == null) then
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            else
              inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
        in
        [ ../hosts/nixos ] ++ inputs.nixpkgs.lib.optionals isISO [ cd-dvd ];
    };

  mkDarwin =
    { desktop ? "aqua"
    , hostname
    , username ? "joseph"
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
          desktop
          hostname
          platform
          username
          isInstall
          isISO
          isLaptop
          isWorkstation
          ;
      };
      modules = [ ../hosts/darwin ];
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
