#!/usr/bin/env bash
set -Eeuo pipefail

mode="dry-run"
assume_yes=false

usage() {
  cat <<'EOF'
Usage:
  sudo ./scripts/repair-galaxy-state-ownership.sh [--dry-run]
  sudo ./scripts/repair-galaxy-state-ownership.sh --execute [--yes]

Repairs only container-era numeric owners in migrated service directories.
It does not remove, rename, overwrite, or alter file contents or modes. Matching
services are stopped and deliberately left stopped for the next NixOS switch.

Options:
  --dry-run  Show the exact ownership changes. This is the default.
  --execute  Apply ownership changes.
  --yes      Skip the interactive confirmation.
  -h, --help Show this help.
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      mode="dry-run"
      ;;
    --execute)
      mode="execute"
      ;;
    --yes)
      assume_yes=true
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ $EUID -ne 0 ]]; then
  printf 'Run this script with sudo.\n' >&2
  exit 1
fi

for command in find getent systemctl; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Required command is unavailable: %s\n' "$command" >&2
    exit 1
  fi
done

labels=(
  "Forgejo"
  "Radicale"
  "Grocy"
  "Wakapi DynamicUser storage"
)
paths=(
  "/var/lib/forgejo"
  "/var/lib/radicale"
  "/var/lib/grocy"
  "/var/lib/private/wakapi"
)
old_uids=(998 995 990 991)
old_gids=(998 995 "" 989)
new_users=(forgejo radicale grocy nobody)
new_groups=(forgejo radicale nginx nogroup)

service_candidates=(
  forgejo.service
  forgejo-runner-token.service
  gitea-runner-forge.service
  radicale.service
  phpfpm-grocy.service
  wakapi.service
)

if ((${#labels[@]} != ${#paths[@]}
  || ${#labels[@]} != ${#old_uids[@]}
  || ${#labels[@]} != ${#old_gids[@]}
  || ${#labels[@]} != ${#new_users[@]}
  || ${#labels[@]} != ${#new_groups[@]})); then
  printf 'Internal error: ownership mapping arrays differ in length.\n' >&2
  exit 1
fi

printf 'Galaxy ownership repair (%s)\n\n' "$mode"

loaded_units=()
for unit in "${service_candidates[@]}"; do
  if [[ $(systemctl show "$unit" --property=LoadState --value 2>/dev/null || true) == "loaded" ]]; then
    loaded_units+=("$unit")
  fi
done

changes=0
for index in "${!paths[@]}"; do
  path="${paths[$index]}"
  old_uid="${old_uids[$index]}"
  old_gid="${old_gids[$index]}"
  new_user="${new_users[$index]}"
  new_group="${new_groups[$index]}"

  if [[ ! -d $path || -L $path ]]; then
    printf 'SKIP  %-28s missing or not a real directory: %s\n' "${labels[$index]}" "$path"
    continue
  fi
  if ! getent passwd "$new_user" >/dev/null; then
    printf 'Required destination user does not exist: %s\n' "$new_user" >&2
    exit 1
  fi
  if ! getent group "$new_group" >/dev/null; then
    printf 'Required destination group does not exist: %s\n' "$new_group" >&2
    exit 1
  fi

  uid_count="$(find "$path" -xdev -uid "$old_uid" -printf . | wc -c)"
  gid_count=0
  if [[ -n $old_gid ]]; then
    gid_count="$(find "$path" -xdev -gid "$old_gid" -printf . | wc -c)"
  fi

  printf 'CHECK %-28s %s\n' "${labels[$index]}" "$path"
  printf '      UID %s -> %s: %s entries\n' "$old_uid" "$new_user" "$uid_count"
  if [[ -n $old_gid ]]; then
    printf '      GID %s -> %s: %s entries\n' "$old_gid" "$new_group" "$gid_count"
  else
    printf '      Group ownership is intentionally unchanged.\n'
  fi

  changes=$((changes + uid_count + gid_count))
done

if ((${#loaded_units[@]})); then
  printf '\nUnits that will be stopped and left stopped:\n'
  printf '  - %s\n' "${loaded_units[@]}"
fi

if ((changes == 0)); then
  printf '\nNo container-era ownership entries were found; nothing to change.\n'
  exit 0
fi

if [[ $mode == "dry-run" ]]; then
  printf '\nDry run found %d ownership matches.\n' "$changes"
  printf 'Apply them with:\n  sudo %q --execute\n' "$0"
  exit 0
fi

if ! $assume_yes; then
  printf '\nType OWNERSHIP to apply only the mappings above: '
  read -r confirmation
  if [[ $confirmation != "OWNERSHIP" ]]; then
    printf 'Confirmation did not match; nothing was changed.\n'
    exit 1
  fi
fi

if ((${#loaded_units[@]})); then
  printf 'Stopping mapped services; they will remain stopped...\n'
  systemctl stop "${loaded_units[@]}" || true
  for unit in "${loaded_units[@]}"; do
    if systemctl is-active --quiet "$unit" 2>/dev/null; then
      printf 'Unit is still active; refusing to change ownership: %s\n' "$unit" >&2
      exit 1
    fi
  done
fi

for index in "${!paths[@]}"; do
  path="${paths[$index]}"
  old_uid="${old_uids[$index]}"
  old_gid="${old_gids[$index]}"
  new_user="${new_users[$index]}"
  new_group="${new_groups[$index]}"

  if [[ ! -d $path || -L $path ]]; then
    continue
  fi

  printf 'Repairing %s...\n' "${labels[$index]}"
  find "$path" -xdev -uid "$old_uid" -exec chown --no-dereference "$new_user" {} +
  if [[ -n $old_gid ]]; then
    find "$path" -xdev -gid "$old_gid" -exec chown --no-dereference ":$new_group" {} +
  fi

done

remaining=0
for index in "${!paths[@]}"; do
  path="${paths[$index]}"
  [[ -d $path && ! -L $path ]] || continue

  uid_count="$(find "$path" -xdev -uid "${old_uids[$index]}" -printf . | wc -c)"
  gid_count=0
  if [[ -n ${old_gids[$index]} ]]; then
    gid_count="$(find "$path" -xdev -gid "${old_gids[$index]}" -printf . | wc -c)"
  fi
  remaining=$((remaining + uid_count + gid_count))
done

if ((remaining != 0)); then
  printf 'Ownership verification found %d remaining matches. Services remain stopped.\n' "$remaining" >&2
  exit 1
fi

printf '\nOwnership repair completed and verified. No data or backup paths were removed.\n'
printf 'Mapped services remain stopped for the next NixOS switch.\n'
