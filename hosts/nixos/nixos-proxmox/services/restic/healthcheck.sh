#! /usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#systemd nixpkgs#coreutils nixpkgs#curl --command bash
# shellcheck shell=bash

# args: $1 is UUID, $2 is exit status (non-zero in case of failures), $3 is unit name

UUID=$1
EXIT=${2:-0}
NAME=$3

OUTPUT=$(systemctl status "$NAME" -l -n 1000 | tail --bytes 100000)
curl -fsS -m 10 -v --retry 5 "https://hc-ping.com/$UUID/$EXIT" --data-raw "$OUTPUT"
