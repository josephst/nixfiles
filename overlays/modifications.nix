final: prev: {
  # zig_0_12 = prev.zig_0_12.overrideAttrs (_: {
  #   # workaround for https://github.com/NixOS/nixpkgs/issues/317055
  #   strictDeps = !prev.stdenv.cc.isClang;
  # });

  # zwave-js-server = prev.zwave-js-server.overrideAttrs (old: rec {
  #   # to update: run `npm update` in the zwave-js-server repo (or npm install --only-lock-file)
  #   # copy package-lock.json to the patches dir
  #   # update the npmDepsHash with `nix run nixpkgs#prefetch-npm-deps package-lock.json`
  #   # patches = (old.patches or [ ]) ++ [
  #   #   ./zwave-js-server/logging-unknown-type.patch
  #   # ];
  #   postPatch = ''
  #     cp ${./zwave-js-server/package-lock.json} ./package-lock.json
  #   '';
  #   npmDeps = final.fetchNpmDeps {
  #     inherit postPatch;
  #     inherit (old) src;
  #     hash = "sha256-ECdmSOugInD7JFEvjkeQfMyrJzKhOIQHs3MwOFEpoSk=";
  #   };
  # });

  # remove once https://nixpk.gs/pr-tracker.html?pr=414065 is merged
  libfaketime = prev.stable.libfaketime;

  home-assistant-custom-components =
    let
      inherit (final.home-assistant.python.pkgs) callPackage;
    in
    prev.home-assistant-custom-components
    // {
      smartrent = callPackage ../pkgsLinux/homeassistant-customcomponents/smartrent/package.nix { };
    };
}
