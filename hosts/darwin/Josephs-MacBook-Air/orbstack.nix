_: {
  home-manager.users.root.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      orb = {
        hostname = "127.0.0.1";
        port = 32222;
        user = "default";
        identitiesOnly = true;
        identityFile = "/Users/joseph/.orbstack/ssh/id_ed25519";
        # proxyCommand = "'/Applications/OrbStack.app/Contents/Frameworks/OrbStack Helper.app/Contents/MacOS/OrbStack Helper' ssh-proxy-fdpass 501";
        # extraOptions = {
        #   "ProxyUseFdpass" = "yes";
        # };
      };
    };
  };

  nix = {
    buildMachines = [
      {
        hostName = "nixos@orb";
        system = "aarch64-linux";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
      {
        hostName = "nixos@orb";
        system = "x86_64-linux";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];
    distributedBuilds = true;
  };

  homebrew.casks = [ "orbstack" ];
}
