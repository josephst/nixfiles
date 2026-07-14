{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  isServer = osConfig.hostSpec.role == "server";
in
{
  age.secrets = lib.mkIf isServer {
    "1password-serviceacct.env".file = ../secrets/1pass.env.age;
    # Same value as above without the OP_SERVICE_ACCOUNT_TOKEN assignment;
    # Fish consumes the token rather than an environment file.
    "1password-serviceacct-fish".file = ../secrets/1pass.age;
  };

  programs.fish.interactiveShellInit = lib.mkIf isServer (
    lib.mkAfter ''
      if test -r "$XDG_RUNTIME_DIR/agenix/1password-serviceacct-fish"
        set -x OP_SERVICE_ACCOUNT_TOKEN (${pkgs.coreutils}/bin/cat "$XDG_RUNTIME_DIR/agenix/1password-serviceacct-fish")
      end
    ''
  );
}
