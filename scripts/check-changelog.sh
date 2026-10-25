#!/usr/bin/env bash
# Fail unless CHANGELOG.md has a non-empty "## <version>" section.
#
# usage: check-changelog.sh <changelog> <version>
set -euo pipefail

changelog=$1
version=$2

entries=$(awk -v h="## $version" '
  $0 == h { found = 1; next }
  found && /^## / { exit }
  found && NF { print }
' "$changelog")

if [ -z "$entries" ]; then
  echo "ERROR: no entries under '## $version' in $changelog" >&2
  exit 1
fi

echo "OK: $changelog has entries for $version:"
echo "$entries"
