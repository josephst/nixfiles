{ config, ... }:
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
        # Connect to OrbStack's local SSH listener directly. The GUI helper
        # depends on the logged-in user's macOS session and fails when the Nix
        # daemon invokes it as root.
        HostName = "127.0.0.1";
        Port = 32222;
        User = "default";
        IdentitiesOnly = true;
        IdentityFile = "/Users/${config.hostSpec.username}/.orbstack/ssh/id_ed25519";
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
