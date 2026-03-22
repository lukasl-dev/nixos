#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <nvf-ref> <manual-path>" >&2
  echo "Example: $0 main configuration/customizing" >&2
  exit 1
fi

ref="$1"
path="$2"
url="https://raw.githubusercontent.com/NotAShelf/nvf/${ref}/docs/manual/${path}.md"

curl --fail --silent --show-error "$url"
