#!/usr/bin/env bash
# Fail unless the addon's image exists on GHCR with <tag> for every arch in its config.yaml.
#
# usage: check-image.sh <addon_dir> <tag>
set -euo pipefail

addon_dir=$1
tag=$2
config="$addon_dir/config.yaml"

image=$(sed -n 's/^image: "\(.*\)"/\1/p' "$config")
arches=$(sed -n '/^arch:/,/^[^ ]/s/^  - //p' "$config")

for arch in $arches; do
  ref=${image//\{arch\}/$arch}
  repo=${ref#ghcr.io/}
  token=$(curl -fsSL "https://ghcr.io/token?scope=repository:$repo:pull" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
  if curl -fsSI -o /dev/null \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.oci.image.index.v1+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json" \
      "https://ghcr.io/v2/$repo/manifests/$tag"; then
    echo "OK: $ref:$tag"
  else
    echo "ERROR: $ref:$tag not found" >&2
    exit 1
  fi
done
