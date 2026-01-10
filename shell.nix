# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{
  pkgs ? (import ./nixpkgs.nix) { },
}:
{
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    packages = with pkgs; [
      # agenix
      nixfmt
      bashInteractive
      curl
      git
      helix
      home-manager
      starship
    ];
    # shellHook = ''
    #   eval "$(${pkgs.starship}/bin/starship init bash)"
    # '';
  };
}
