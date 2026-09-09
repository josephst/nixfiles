{
  runCommand,
  bash,
  coreutils,
  python3,
  shellcheck,
}:

runCommand "brscan-skey-tests"
  {
    nativeBuildInputs = [
      bash
      coreutils
      python3
      shellcheck
    ];
  }
  ''
    cp ${./scantofile.sh} scantofile.sh
    cp ${./test_scantofile.py} test_scantofile.py
    shellcheck scantofile.sh
    python3 test_scantofile.py
    touch "$out"
  ''
