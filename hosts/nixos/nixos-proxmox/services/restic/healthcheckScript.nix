{lib, pkgs, ...}:
''
  # args: $1 is UUID, $2 is exit status (non-zero in case of failures), $3 is unit name

  UUID=$1
  EXIT=''${2:-0} # two single quotes are the escape sequence here
  NAME=$3
  
  OUTPUT=$(${pkgs.systemd}/bin/systemctl status $NAME -l -n 1000 | ${pkgs.coreutils}/bin/tail --bytes 100000)
  ${lib.getExe pkgs.curl} -fsS -m 10 -v --retry 5 "https://hc-ping.com/$UUID/$EXIT" --data-raw "$OUTPUT"
''
