{ pkgs, lib, ... }:
# TODO: try and centralize this section/ refactor into a config.key... module
# public key is written to disk, private key stays in password manager
let
  macbookAirPubKey = pkgs.writeText "macbookAirPubKey" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbookair";
  nixosProxmoxPubKey = pkgs.writeText "nixosPubKey" "AAAAC3NzaC1lZDI1NTE5AAAAICBTyMi+E14e8/droY9+Xg7ORNMMdgH1i6LsfDyKZSy4 joseph@nixos-proxmox";
  identityFile = "${macbookAirPubKey} ${nixosProxmoxPubKey}";
in
{
  programs.ssh = {
    enable = true;
    matchBlocks =
      {
        "nixos nixos.josephstahl.com" = {
          hostname = "nixos";
          user = "joseph";
          forwardAgent = true;
          inherit identityFile;
        };
        "proxmox proxmox.josephstahl.com" = {
          hostname = "proxmox";
          user = "root";
          forwardAgent = true;
          inherit identityFile;
        };
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        "*".extraOptions = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
  };
}
