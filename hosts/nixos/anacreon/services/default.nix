{
  imports = [
    ./acme.nix
    ./backrest.nix
    ./backrest-backup.nix
    ./caddy.nix
    ./copyparty.nix
    ./paperless-backup.nix
    ./paperless.nix
    ./restic-repository.nix
    ./tailscale-auth.nix
    ./tailscale-serve.nix
    ./homepage
    ../../common/mixins/tailscale.nix
  ];
}
