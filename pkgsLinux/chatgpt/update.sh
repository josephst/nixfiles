#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils curl dpkg gnused nix
# shellcheck shell=bash

set -euo pipefail

url="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb"
package_path="${1:?package path is required}"
deb="$(mktemp)"
trap 'rm -f "$deb"' EXIT

curl --fail --location --silent --show-error --output "$deb" "$url"

version="$(dpkg-deb --field "$deb" Version)"
hash="$(nix hash file "$deb")"
repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/$package_path"

sed --in-place --regexp-extended \
  --expression="s|^([[:space:]]*version = )\"[^\"]+\";|\1\"$version\";|" \
  --expression="s|^([[:space:]]*hash = )\"sha256-[^\"]+\";|\1\"$hash\";|" \
  "$package_file"

printf 'chatgpt: updated to %s (%s)\n' "$version" "$hash"
