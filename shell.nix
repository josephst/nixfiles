# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{pkgs ? (import ./nixpkgs.nix) {
  overlays = [ ];
}}: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      agenix
      alejandra
      bash
      curl
      git
      home-manager
      neovim
      nix
      starship

      # TODO: delete this testing section
      (python310.withPackages (ps: [ps.influxdb]))
      # python3
      # python310Packages.influxdb2
    ];
    shellHook = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
  };
}
