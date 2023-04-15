{...}: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*".extraOptions = {
        IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };
      "nixos" = {
        hostname = "nixos";
        user = "joseph";
      };
    };
  };
}
