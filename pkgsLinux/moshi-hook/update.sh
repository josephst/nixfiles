#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils curl git gnused nix
# shellcheck shell=bash

set -euo pipefail

cdn="https://cdn.getmoshi.app"
package_path="${1:?package path is required}"
version="$(curl --fail --location --silent --show-error "$cdn/hook/latest/version.txt")"
version="${version//[[:space:]]/}"

if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'unexpected moshi-hook version: %q\n' "$version" >&2
  exit 1
fi

checksums="$(curl --fail --location --silent --show-error "$cdn/hook/$version/checksums.txt")"

hash_for() {
  local asset="$1"
  local hash

  hash="$(awk -v asset="$asset" '$2 == asset { print $1 }' <<< "$checksums")"
  if [[ ! "$hash" =~ ^[0-9a-f]{64}$ ]]; then
    printf 'missing or invalid checksum for %s\n' "$asset" >&2
    exit 1
  fi

  nix hash convert --hash-algo sha256 --to sri "$hash"
}

x86_64_hash="$(hash_for moshi-hook_Linux_x86_64.tar.gz)"
aarch64_hash="$(hash_for moshi-hook_Linux_arm64.tar.gz)"
repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/$package_path"

sed --in-place --regexp-extended \
  --expression="s|^([[:space:]]*version = )\"[^\"]+\";|\1\"${version#v}\";|" \
  --expression="s|^([[:space:]]*x86_64Hash = )\"sha256-[^\"]+\";|\1\"$x86_64_hash\";|" \
  --expression="s|^([[:space:]]*aarch64Hash = )\"sha256-[^\"]+\";|\1\"$aarch64_hash\";|" \
  "$package_file"

printf 'moshi-hook: updated to %s\n' "${version#v}"
