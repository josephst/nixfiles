{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "healthchecks-ping";
  runtimeInputs = with pkgs; [
    systemd
    coreutils
    curl
  ];
  text = ''
    UUID=$1
    EXIT=''${2:-0}
    NAME=$3

    OUTPUT=$(systemctl status "$NAME" -l -n 1000 | tail --bytes 100000)
    curl -fsS -m 10 -v --retry 5 "https://hc-ping.com/''${UUID}/''${EXIT}" --data-raw "$OUTPUT"
  '';
}
