{
  imports = [
    # ./acme.nix
    ./backrest.nix
    ./caddy.nix
    ./copyparty.nix
    ./paperless.nix
    ./tailscale-auth.nix
    ./homepage
    ../../common/mixins/tailscale.nix
  ];
}
