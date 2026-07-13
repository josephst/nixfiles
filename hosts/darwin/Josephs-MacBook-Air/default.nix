{ config, ... }:
let
  buildMachines = [
    {
      hostName = "anacreon";
      sshUser = "joseph";
      system = "x86_64-linux";
      speedFactor = 2;
      maxJobs = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      protocol = "ssh-ng";
    }
    # Terminus is currently in storage. Uncomment this builder when the machine
    # returns to service.
    # {
    #   hostName = "terminus";
    #   sshUser = "joseph";
    #   system = "x86_64-linux";
    #   speedFactor = 3;
    #   maxJobs = 6;
    #   supportedFeatures = [
    #     "nixos-test"
    #     "benchmark"
    #     "big-parallel"
    #     "kvm"
    #   ];
    #   protocol = "ssh-ng";
    # }
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
    inherit (config.nix) buildMachines;
    distributedBuilds = true;
  };

  system.stateVersion = 6;
  home-manager.users.${config.hostSpec.username}.home.stateVersion = "26.05";
  # nix-darwin exposes root to Home Manager even though it has no imported
  # profile; keep its migration contract local to this host.
  home-manager.users.root.home.stateVersion = "25.11";
}
