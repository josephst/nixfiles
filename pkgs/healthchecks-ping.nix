{ writeShellApplication
, coreutils
, curl
, ...
}:

writeShellApplication {
  name = "healthchecks-ping";
  runtimeInputs = [
    coreutils
    curl
  ];
  text = ''
    UUID=$1
    EXIT=''${2:-0}
    NAME=$3

    OUTPUT=$(journalctl -u "$NAME" --since=yesterday --no-pager | tail --bytes 100000)

    curl -fsS -m 10 -v --retry 5 "https://hc-ping.com/''${UUID}/''${EXIT}" --data-raw "$OUTPUT"
  '';
}
