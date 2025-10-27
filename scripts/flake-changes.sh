#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == "" ]]; then
  echo "usage: flake-changes <input-name>" >&2
  exit 2
fi

input="$1"

# New (working tree)
new_type=$(jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.type // empty' flake.lock)
new_owner=$(jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.owner // empty' flake.lock)
new_repo=$(jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.repo // empty' flake.lock)
new_rev=$(jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.rev // empty' flake.lock)

# Old (HEAD)
if git show HEAD:flake.lock >/dev/null 2>&1; then
  old_type=$(git show HEAD:flake.lock | jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.type // empty')
  old_owner=$(git show HEAD:flake.lock | jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.owner // empty')
  old_repo=$(git show HEAD:flake.lock | jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.repo // empty')
  old_rev=$(git show HEAD:flake.lock | jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.rev // empty')
else
  old_type=""; old_owner=""; old_repo=""; old_rev=""
fi

echo "input: $input"
echo "type:  ${new_type:-unknown}"
echo "old:   ${old_rev:-<none>}"
echo "new:   ${new_rev:-<none>}"

if [[ -z ${new_rev:-} ]]; then
  echo "error: input not found in working flake.lock" >&2
  exit 1
fi

if [[ "${old_rev:-}" == "$new_rev" || -z ${old_rev:-} ]]; then
  if [[ -z ${old_rev:-} ]]; then
    echo "no HEAD:flake.lock entry to compare against"
  else
    echo "no change"
  fi
  exit 0
fi

# Build a git remote URL from lock data
remote=""
label=""
case "$new_type" in
  github)
    if [[ -n ${new_owner:-} && -n ${new_repo:-} ]]; then
      remote="https://github.com/${new_owner}/${new_repo}.git"
      label="${new_owner}/${new_repo}"
    fi
    ;;
  gitlab)
    if [[ -n ${new_owner:-} && -n ${new_repo:-} ]]; then
      remote="https://gitlab.com/${new_owner}/${new_repo}.git"
      label="${new_owner}/${new_repo} (gitlab)"
    fi
    ;;
  git)
    new_url=$(jq -r --arg i "$input" 'def nid($i): (.nodes.root.inputs[$i]? // $i) | if type=="string" then . elif (type=="array" and length>0) then .[0] else $i end; .nodes[(nid($i))].locked.url // empty' flake.lock)
    if [[ -n ${new_url:-} ]]; then
      remote="$new_url"
      label="$new_url"
    fi
    ;;
esac

if [[ -z $remote ]]; then
  echo "no git remote derivable for type '${new_type}', showing revs only"
  exit 0
fi

echo "source: ${label}"

# Simple git cache under repo .git/flake-sources
cache_root=".git/flake-sources"
mkdir -p "$cache_root"
remote_key=$(printf '%s' "$remote" | sha1sum | cut -d' ' -f1)
cache="$cache_root/$remote_key.git"

if [[ ! -d "$cache" ]]; then
  git clone --mirror --filter=blob:none "$remote" "$cache" >/dev/null 2>&1 || git clone --mirror "$remote" "$cache" >/dev/null 2>&1
else
  git -C "$cache" remote set-url origin "$remote" >/dev/null 2>&1 || true
  git -C "$cache" fetch --prune --tags --force --filter=blob:none origin >/dev/null 2>&1 || git -C "$cache" fetch --prune --tags --force origin >/dev/null 2>&1
fi

# Ensure both SHAs are present
for r in "$old_rev" "$new_rev"; do
  if ! git -C "$cache" cat-file -e "$r^{commit}" 2>/dev/null; then
    git -C "$cache" fetch --filter=blob:none origin "$r" >/dev/null 2>&1 || git -C "$cache" fetch origin "$r" >/dev/null 2>&1 || true
  fi
done

if ! git -C "$cache" cat-file -e "$old_rev^{commit}" 2>/dev/null || ! git -C "$cache" cat-file -e "$new_rev^{commit}" 2>/dev/null; then
  echo "(could not fetch one or both SHAs; showing revs only)"
  exit 0
fi

# Show commits between old..new
count=$(git -C "$cache" rev-list --count "$old_rev..$new_rev" || echo 0)
echo "commits: $count between ${old_rev:0:7} and ${new_rev:0:7}"
if [[ "$count" != "0" ]]; then
  git -C "$cache" log --format='- %h %cI: %s' --reverse "$old_rev..$new_rev"
fi
