{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  isServer = osConfig.hostSpec.role == "server";
  isDarwinWorkstation = isDarwin && osConfig.hostSpec.role == "workstation";

  fastmailMcpHeadersHelper = pkgs.writeShellApplication {
    name = "codex-fastmail-mcp-headers";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      /usr/bin/security find-generic-password \
        -a ${lib.escapeShellArg osConfig.hostSpec.username} \
        -s com.openai.codex.fastmail-mcp \
        -w \
      | jq -Rs '
        sub("[\\r\\n]+$"; "")
        | if length == 0 then
            error("Fastmail MCP token is empty")
          else
            { Authorization: ("Bearer " + .) }
          end
      '
    '';
  };
in
{
  age.secrets = lib.mkIf isServer {
    "1password-serviceacct.env".file = ../secrets/1pass.env.age;
    # Same value as above without the OP_SERVICE_ACCOUNT_TOKEN assignment;
    # Fish consumes the token rather than an environment file.
    "1password-serviceacct-fish".file = ../secrets/1pass.age;
  };

  home.file.".local/bin/codex-fastmail-mcp-headers" = lib.mkIf isDarwinWorkstation {
    force = true;
    source = lib.getExe fastmailMcpHeadersHelper;
  };

  programs.fish.interactiveShellInit = lib.mkIf isServer (
    lib.mkAfter ''
      if test -r "$XDG_RUNTIME_DIR/agenix/1password-serviceacct-fish"
        set -x OP_SERVICE_ACCOUNT_TOKEN (${pkgs.coreutils}/bin/cat "$XDG_RUNTIME_DIR/agenix/1password-serviceacct-fish")
      end
    ''
  );
}
