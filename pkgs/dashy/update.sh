#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl common-updater-scripts nodePackages.node2nix gnused nix coreutils jq

set -euo pipefail

latestVersion="$(curl -s "https://api.github.com/repos/lissy93/dashy/releases?per_page=1" | jq -r ".[0].tag_name")"
currentVersion=$(nix-instantiate --eval -E "with import ./. {}; dashy.version or (lib.getVersion dashy)" | tr -d '"')

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "dashy is up-to-date: $currentVersion"
  exit 0
fi

update-source-version dashy 0 0000000000000000000000000000000000000000000000000000000000000000
update-source-version dashy "$latestVersion"

# use patched source
store_src="$(nix-build . -A dashy.src --no-out-link)"

cd "$(dirname "${BASH_SOURCE[0]}")"

node2nix \
  --nodejs-18 \
  --development \
  --node-env ./node-env.nix \
  --output ./node-deps.nix \
  --input "$store_src/package.json" \
  --composition ./node-composition.nix
