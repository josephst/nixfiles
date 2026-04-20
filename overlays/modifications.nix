final: prev: {
  home-assistant-custom-components =
    let
      inherit (final.home-assistant.python.pkgs) callPackage;
    in
    prev.home-assistant-custom-components
    // {
      smartrent = callPackage ../pkgsLinux/homeassistant-customcomponents/smartrent/package.nix { };
    };

  # TODO: remove once https://github.com/NixOS/nixpkgs/pull/510439 is available in nixpkgs-unstable.
  nushell = prev.nushell.overrideAttrs (old: {
    checkPhase =
      builtins.replaceStrings
        [
          "--skip=shell::environment::env::path_is_a_list_in_repl"
        ]
        [
          "--skip=shell::environment::env::env_shlvl_in_exec_repl --skip=shell::environment::env::env_shlvl_in_repl --skip=shell::environment::env::path_is_a_list_in_repl"
        ]
        old.checkPhase;
  });

  # zwave-js-server = prev.zwave-js-server.overrideAttrs (
  #   _: old: rec {
  #     version = "3.2.1";
  #     src = old.src.override {
  #       rev = version;
  #       hash = "sha256-oZA+tMYxiWc+PiPiqGEJpEa434CqNjPbutBWjXBgmhw=";
  #     };
  #     npmDeps = final.fetchNpmDeps {
  #       inherit src;
  #       hash = "sha256-1JgfXF3kNuUj0jprKBsJSPeFH6ZpqpU4lceTQm5FBgg=";
  #     };
  #   }
  # );

}
