#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <nvf-ref>" >&2
  echo "Example: $0 main" >&2
  exit 1
fi

ref="$1"
url="https://api.github.com/repos/NotAShelf/nvf/git/trees/${ref}?recursive=1"

json=$(curl --fail --silent --show-error \
  --header 'User-Agent: pi-mono/1.0 (+https://github.com/lukasl-dev/rime)' \
  "$url")

JSON_INPUT="$json" python3 -c '
import json
import os
import sys

data = json.loads(os.environ["JSON_INPUT"])
items = data.get("tree")
if not isinstance(items, list):
    raise SystemExit("GitHub API response missing tree array")

prefix = "docs/manual/"
paths = []
for item in items:
    path = item.get("path")
    kind = item.get("type")
    if kind == "blob" and isinstance(path, str) and path.startswith(prefix) and path.endswith(".md"):
        paths.append(path[len(prefix):-3])

json.dump(sorted(paths), sys.stdout)
sys.stdout.write("\n")
'
