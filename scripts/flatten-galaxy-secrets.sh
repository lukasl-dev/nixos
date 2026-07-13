#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git -C "${BASH_SOURCE[0]%/*}" rev-parse --show-toplevel)"
source_dir="$repo_root/secrets/galaxy/lukasl-dev"
destination_dir="$repo_root/secrets/galaxy"
old_path="secrets/galaxy/lukasl-dev/"
new_path="secrets/galaxy/"

if [[ $EUID -eq 0 ]]; then
  printf 'Run this script as your regular user; it invokes sudo only for protected secret files.\n' >&2
  exit 1
fi

needs_sudo=false
if [[ ! -r $destination_dir ]] || [[ ! -x $destination_dir ]] || [[ ! -w $destination_dir ]]; then
  needs_sudo=true
  if ! command -v sudo >/dev/null; then
    printf 'The secret directory requires elevated access, but sudo is unavailable.\n' >&2
    exit 1
  fi
fi

run_secret_command() {
  if $needs_sudo; then
    sudo -- "$@"
  else
    "$@"
  fi
}

if ! run_secret_command test -d "$destination_dir"; then
  printf 'Destination directory does not exist: %s\n' "$destination_dir" >&2
  exit 1
fi

if run_secret_command test -d "$source_dir"; then
  entries=()
  while IFS= read -r -d '' entry; do
    entries+=("$entry")
  done < <(run_secret_command find "$source_dir" -mindepth 1 -maxdepth 1 -print0)

  # Check every destination before moving anything, so a name collision cannot
  # leave the hierarchy half-migrated.
  for entry in "${entries[@]}"; do
    name="${entry##*/}"
    target="$destination_dir/$name"
    if run_secret_command test -e "$target" || run_secret_command test -L "$target"; then
      printf 'Refusing to overwrite existing destination: %s\n' "$target" >&2
      exit 1
    fi
  done

  if ((${#entries[@]})); then
    printf 'Moving %d entries from %s to %s\n' \
      "${#entries[@]}" "$source_dir" "$destination_dir"
    for entry in "${entries[@]}"; do
      run_secret_command mv -- "$entry" "$destination_dir/"
    done
  fi

  run_secret_command rmdir -- "$source_dir"
else
  printf 'Source directory is already absent; only references will be checked.\n'
fi

python3 - "$repo_root" "$old_path" "$new_path" <<'PY'
from pathlib import Path
import sys

repo = Path(sys.argv[1])
old = sys.argv[2]
new = sys.argv[3]
changed = []

paths = list(repo.glob("*.nix"))
for directory in (repo / "options", repo / "planets"):
    paths.extend(directory.rglob("*.nix"))

for path in paths:
    text = path.read_text()
    updated = text.replace(old, new)
    if updated != text:
        path.write_text(updated)
        changed.append(path.relative_to(repo))

if changed:
    print("Updated secret paths in:")
    for path in changed:
        print(f"  {path}")
else:
    print("No old Nix secret paths remained.")
PY

if grep -R --line-number --fixed-strings \
  --include='*.nix' --exclude-dir='.git' \
  "$old_path" "$repo_root/options" "$repo_root/planets" "$repo_root/universe.nix"; then
  printf 'Old secret references remain; inspect the matches above.\n' >&2
  exit 1
fi

printf '\nGalaxy secrets are now under %s\n' "$destination_dir"
printf 'Review the result with: git status --short\n'
