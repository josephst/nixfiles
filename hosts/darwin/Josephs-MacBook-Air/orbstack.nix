_:
let
  supportedFeatures = [
    "nixos-test"
    "benchmark"
    "big-parallel"
  ];
in
{
  home-manager.users.root.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
      orb = {
        HostName = "127.0.0.1";
        Port = 32222;
        User = "default";
        IdentitiesOnly = true;
        IdentityFile = "/Users/joseph/.orbstack/ssh/id_ed25519";
        ProxyCommand = "env HOME=/Users/joseph '/Applications/OrbStack.app/Contents/Frameworks/OrbStack Helper.app/Contents/MacOS/OrbStack Helper' ssh-proxy-fdpass";
        ProxyUseFdpass = "yes";
      };
    };
  };

  nix = {
    buildMachines = [
      {
        hostName = "nixos@orb";
        system = "aarch64-linux";
        inherit supportedFeatures;
      }
      {
        hostName = "nixos@orb";
        system = "x86_64-linux";
        inherit supportedFeatures;
      }
    ];
    distributedBuilds = true;
  };

  homebrew.casks = [ "orbstack" ];
}
