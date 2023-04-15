# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{pkgs ? (import ./nixpkgs.nix) {}}: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = builtins.attrValues {
      inherit
        (pkgs)
        agenix
        alejandra
        bash
        curl
        git
        home-manager
        neovim
        nix
        starship
        ;
    };
    shellHook = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
  };
}
