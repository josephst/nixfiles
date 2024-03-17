{
  pkgs,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    matchBlocks =
      {
        "nixos" = {
          hostname = "nixos";
          user = "joseph";
          forwardAgent = true;
        };
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        "*".extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
  };
}
