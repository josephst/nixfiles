{ config, ... }:
let
  buildMachines = [
    {
      hostName = "terminus";
      sshUser = "joseph";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      protocol = "ssh-ng";
    }
  ];
in
{
  imports = [
    # global config
    ../common # nix-darwin
    ../../common # nix-darwin AND NixOS

    # machine-specific config
    ./brew.nix
    ./orbstack.nix
  ];

  nix = {
    inherit buildMachines;
  };
  determinateNix = {
    buildMachines = config.nix.buildMachines;
    distributedBuilds = true;
  };
}
