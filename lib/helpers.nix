# modified from https://github.com/wimpysworld/nix-config (MIT)
{
  inputs,
  outputs,
  ...
}:
{
  # Helper function for generating NixOS configs
  mkNixos =
    {
      hostSpec,
      myConfig,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = (builtins.attrValues outputs.nixosModules) ++ [
        ../hosts/nixos/${hostSpec.hostName}
        { inherit hostSpec myConfig; }
      ];
    };

  mkDarwin =
    {
      hostSpec,
      myConfig,
    }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = (builtins.attrValues outputs.darwinModules) ++ [
        ../hosts/darwin/${hostSpec.hostName}
        { inherit myConfig hostSpec; }
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
