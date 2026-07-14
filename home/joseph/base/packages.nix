{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  isMinimal = osConfig.hostSpec.cliProfile == "minimal";
in
{
  home.packages =
    with pkgs;
    [
      age # encryption
      agenix # age secrets
      bc # calculator
      comma # run commands by prefacing with comma
      cpufetch # CPU info
      cyme # modern lsusb

      doggo # better dig
      dua # modern du
      duf # modern df
      ipfetch # IP info
      just # command runner
      ncdu # TUI disk usage
      nixd # Nix LSP
      nixfmt # nix formatter
      nixpkgs-hammering # nixpkgs linter
      nixpkgs-review # review PRs
      nix-prefetch-scripts # nix code fetcher
      nix-update # update nixpkgs
      nurl # nix url fetcher
      procs # modern ps
      rclone # syncing
      restic # backup
      rsync # syncing
    ]
    ++ lib.optionals (!isMinimal) [
      diffsitter # better diff
      glow # markdown on terminal
      httpie # better curl
      hugo # static website builder
      hyperfine # command-line benchmarking
      magic-wormhole
      speedtest-go # speedtest CLI
      (python3.withPackages (
        python-pkgs: with python-pkgs; [
          pyyaml
        ]
      )) # python
      tealdeer # cheatsheets in terminal
      yt-dlp # youtube-dl
    ]
    ++ lib.optionals isLinux [
      iw # terminal wifi info
      pciutils # PCI info
      s-tui # stress test
      usbutils # USB info
    ]
    ++ lib.optionals isDarwin [
      nh # nix client (on NixOS, this is a module)
      coreutils # macOS coreutils
      git-credential-manager
    ];

  home.sessionPath = lib.optional config.programs.npm.enable "$HOME/.npm/bin";
}
