{
  imports = [
    ./backrest.nix
    ./caddy.nix
    ./copyparty.nix
    ./paperless-backup.nix
    ./paperless.nix
    ./tailscale-auth.nix
    ./homepage
    ../../common/mixins/tailscale.nix
  ];
}
