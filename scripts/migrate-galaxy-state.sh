#!/usr/bin/env bash
set -Eeuo pipefail

readonly default_source_root="/var/lib/nixos-containers/lukasl-dev"
readonly safety_margin_bytes=$((64 * 1024 * 1024))

mode="dry-run"
assume_yes=false
source_root="$default_source_root"

usage() {
  cat <<'EOF'
Usage:
  sudo ./scripts/migrate-galaxy-state.sh [--dry-run]
  sudo ./scripts/migrate-galaxy-state.sh --execute [--yes]

Options:
  --dry-run           Perform all safety checks and print the migration plan.
                      This is the default.
  --execute           Copy and activate the migrated directories.
  --yes               Skip the interactive confirmation used with --execute.
  --source-root PATH  Override the old container root.
  -h, --help          Show this help.

The script stops matching services inside the NixOS container and on the host,
and deliberately leaves them stopped for cutover. It never deletes source data.
Existing destinations are renamed to <destination>.bak-<UTC timestamp>, and
source data is first copied and verified in a temporary sibling before it is
atomically renamed into place.
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      mode="dry-run"
      shift
      ;;
    --execute)
      mode="execute"
      shift
      ;;
    --yes)
      assume_yes=true
      shift
      ;;
    --source-root)
      if (($# < 2)); then
        printf '%s\n' '--source-root requires a path.' >&2
        exit 2
      fi
      source_root="${2%/}"
      shift 2
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
done

if [[ $EUID -ne 0 ]]; then
  printf 'Run this script as root, for example:\n  sudo %q --dry-run\n' "$0" >&2
  exit 1
fi

for command in awk date df du findmnt readlink rsync systemctl; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Required command is unavailable: %s\n' "$command" >&2
    exit 1
  fi
done

if [[ ! -d $source_root || -L $source_root ]]; then
  printf 'The source root must be an existing, real directory: %s\n' "$source_root" >&2
  exit 1
fi

source_root="$(readlink -f -- "$source_root")"
if [[ $source_root == "/" ]]; then
  printf 'Refusing to use the filesystem root as the container source.\n' >&2
  exit 1
fi
readonly source_root
readonly timestamp="$(date -u +'%Y%m%dT%H%M%S.%NZ')"

# Every path has the same location inside the old container and on the host.
# Missing source directories are expected for services that were never enabled.
labels=(
  "Anki sync server"
  "Audiobookshelf"
  "Homebox"
  "Radicale"
  "Factorio"
  "Forgejo and runner"
  "Pi-hole configuration"
  "Pi-hole state"
  "Home Assistant"
  "Grocy"
  "Tuwunel"
  "NetBird"
  "Uptime Kuma"
  "Vaultwarden"
  "Wakapi"
  "Yamtrack"
  "Yamtrack Redis"
)

destinations=(
  "/var/lib/private/anki-sync-server"
  "/var/lib/audiobookshelf"
  "/var/lib/homebox"
  "/var/lib/radicale"
  "/var/lib/private/factorio"
  "/var/lib/forgejo"
  "/etc/pihole"
  "/var/lib/pihole"
  "/var/lib/hass"
  "/var/lib/grocy"
  "/var/lib/private/tuwunel"
  "/var/lib/netbird"
  "/var/lib/private/uptime-kuma"
  "/var/lib/vaultwarden"
  "/var/lib/private/wakapi"
  "/var/lib/yamtrack"
  "/var/lib/yamtrack-redis"
)

# Candidate host units for each destination. Only units loaded by the current
# host configuration are managed. Multiple spellings cover module-version
# differences; canonical systemd unit IDs are deduplicated before use.
unit_sets=(
  "anki-sync-server.service"
  "audiobookshelf.service"
  "homebox.service"
  "radicale.service"
  "factorio.service"
  "forgejo.service gitea-runner-forge.service"
  "pihole-ftl.service pihole-FTL.service pihole-web.service"
  "pihole-ftl.service pihole-FTL.service pihole-web.service"
  "home-assistant.service"
  "phpfpm-grocy.service"
  "matrix-tuwunel.service"
  "netbird-server.service"
  "uptime-kuma.service"
  "vaultwarden.service"
  "wakapi.service"
  "docker-yamtrack.service"
  "docker-yamtrack-redis.service"
)

if ((${#labels[@]} != ${#destinations[@]} || ${#labels[@]} != ${#unit_sets[@]})); then
  printf 'Internal error: migration labels, paths, and units differ in length.\n' >&2
  exit 1
fi

path_exists() {
  [[ -e $1 || -L $1 ]]
}

printf 'Galaxy state migration (%s)\n' "$mode"
printf 'Source container root: %s\n' "$source_root"
printf 'Backup suffix: .bak-%s\n\n' "$timestamp"

# Copying live container state cannot produce a trustworthy snapshot.
active_container_checks=()
for unit in container@lukasl-dev.service systemd-nspawn@lukasl-dev.service; do
  if systemctl is-active --quiet "$unit" 2>/dev/null; then
    active_container_checks+=("systemd unit $unit")
  fi
done

if command -v machinectl >/dev/null 2>&1; then
  machine_state="$(machinectl show lukasl-dev --property=State --value 2>/dev/null || true)"
  case "$machine_state" in
    running | degraded | starting)
      active_container_checks+=("machinectl state $machine_state")
      ;;
  esac
fi

if command -v nixos-container >/dev/null 2>&1; then
  container_status="$(nixos-container status lukasl-dev 2>/dev/null || true)"
  if [[ $container_status == "UP" ]]; then
    active_container_checks+=("nixos-container reports UP")
  fi
fi

container_active=false
if ((${#active_container_checks[@]})); then
  container_active=true
  printf 'The old container is active; its relevant inner services will be stopped and left stopped for cutover:\n'
  printf '  - %s\n' "${active_container_checks[@]}"
  if ! command -v nixos-container >/dev/null 2>&1; then
    printf 'nixos-container is required to manage services inside the active container.\n' >&2
    exit 1
  fi
fi

active_indexes=()
declare -A required_by_mount=()
declare -A available_by_mount=()

printf 'Preflight plan:\n'
for index in "${!destinations[@]}"; do
  destination="${destinations[$index]}"
  source="$source_root$destination"
  backup="$destination.bak-$timestamp"
  temporary="$destination.migrating-$timestamp"

  if ! path_exists "$source"; then
    printf '  SKIP  %-24s source is absent: %s\n' "${labels[$index]}" "$source"
    continue
  fi

  if [[ ! -d $source || -L $source ]]; then
    printf 'Source must be a real directory, not a file or symlink: %s\n' "$source" >&2
    exit 1
  fi
  if path_exists "$backup"; then
    printf 'Backup path already exists; refusing to overwrite it: %s\n' "$backup" >&2
    exit 1
  fi
  if path_exists "$temporary"; then
    printf 'Temporary path already exists; refusing to overwrite it: %s\n' "$temporary" >&2
    exit 1
  fi

  parent="$(dirname -- "$destination")"
  existing_parent="$parent"
  while ! path_exists "$existing_parent"; do
    next_parent="$(dirname -- "$existing_parent")"
    if [[ $next_parent == "$existing_parent" ]]; then
      printf 'Could not find an existing parent for %s\n' "$destination" >&2
      exit 1
    fi
    existing_parent="$next_parent"
  done

  mountpoint="$(findmnt --noheadings --output TARGET --target "$existing_parent" | head -n1)"
  if [[ -z $mountpoint ]]; then
    printf 'Could not determine the destination filesystem for %s\n' "$destination" >&2
    exit 1
  fi

  # Apparent size is deliberately conservative for sparse files.
  bytes="$(du --summarize --apparent-size --block-size=1 -- "$source" | awk '{print $1}')"
  required_by_mount["$mountpoint"]=$(( ${required_by_mount["$mountpoint"]:-0} + bytes ))
  available_by_mount["$mountpoint"]="$(df --block-size=1 --output=avail -- "$existing_parent" | awk 'NR == 2 {print $1}')"

  if path_exists "$destination"; then
    printf '  COPY  %-24s %s\n' "${labels[$index]}" "$source"
    printf '        destination exists and will be renamed to:\n        %s\n' "$backup"
  else
    printf '  COPY  %-24s %s\n' "${labels[$index]}" "$source"
    printf '        destination: %s\n' "$destination"
  fi

  active_indexes+=("$index")
done

if ((${#active_indexes[@]} == 0)); then
  printf '\nNo mapped state directories exist below the source root; nothing to do.\n'
  exit 0
fi

container_systemctl() {
  nixos-container run lukasl-dev -- systemctl "$@"
}

managed_host_units=()
managed_container_units=()
declare -A seen_host_units=()
declare -A seen_container_units=()

for index in "${active_indexes[@]}"; do
  read -r -a candidates <<<"${unit_sets[$index]}"
  for candidate in "${candidates[@]}"; do
    load_state="$(systemctl show "$candidate" --property=LoadState --value 2>/dev/null || true)"
    if [[ $load_state == "loaded" ]]; then
      canonical_unit="$(systemctl show "$candidate" --property=Id --value 2>/dev/null || true)"
      canonical_unit="${canonical_unit:-$candidate}"
      if [[ -z ${seen_host_units[$canonical_unit]+set} ]]; then
        seen_host_units["$canonical_unit"]=1
        managed_host_units+=("$canonical_unit")
      fi
    fi

    if $container_active; then
      load_state="$(container_systemctl show "$candidate" --property=LoadState --value 2>/dev/null || true)"
      if [[ $load_state == "loaded" ]]; then
        canonical_unit="$(container_systemctl show "$candidate" --property=Id --value 2>/dev/null || true)"
        canonical_unit="${canonical_unit:-$candidate}"
        if [[ -z ${seen_container_units[$canonical_unit]+set} ]]; then
          seen_container_units["$canonical_unit"]=1
          managed_container_units+=("$canonical_unit")
        fi
      fi
    fi
  done
done

if ((${#managed_container_units[@]})); then
  printf '\nServices inside the NixOS container that will be stopped and left stopped:\n'
  printf '  - %s\n' "${managed_container_units[@]}"
fi
if ((${#managed_host_units[@]})); then
  printf '\nHost services that will be stopped and left stopped:\n'
  printf '  - %s\n' "${managed_host_units[@]}"
fi
if ((${#managed_container_units[@]} == 0 && ${#managed_host_units[@]} == 0)); then
  printf '\nNo corresponding service units are loaded; no services will be managed.\n'
fi

printf '\nDestination filesystem capacity:\n'
for mountpoint in "${!required_by_mount[@]}"; do
  required="${required_by_mount[$mountpoint]}"
  available="${available_by_mount[$mountpoint]}"
  required_with_margin=$((required + required / 10 + safety_margin_bytes))
  printf '  %s: need %s bytes plus 10%% and %s bytes; %s bytes available\n' \
    "$mountpoint" "$required" "$safety_margin_bytes" "$available"
  if ((available < required_with_margin)); then
    printf 'Insufficient free space on %s after applying the safety margin.\n' \
      "$mountpoint" >&2
    exit 1
  fi
done

cat <<'EOF'

Not migrated by this script:
  - /var/www/notes and /var/www/www: these were host bind mounts.
  - Attic, Maddy/Rspamd, and Coturn: these already ran on the host.
  - Restic server dataDir: this was a writable host bind mount.

The original container root is retained unchanged.
EOF

if [[ $mode == "dry-run" ]]; then
  printf '\nDry run completed. To perform the migration, run:\n  sudo %q --execute\n' "$0"
  exit 0
fi

if ! $assume_yes; then
  printf '\nType MIGRATE to copy and activate the directories listed above: '
  read -r confirmation
  if [[ $confirmation != "MIGRATE" ]]; then
    printf 'Confirmation did not match; no files were changed.\n'
    exit 1
  fi
fi

log_file="/var/log/galaxy-state-migration-$timestamp.log"
if path_exists "$log_file"; then
  printf 'Log path already exists; refusing to overwrite it: %s\n' "$log_file" >&2
  exit 1
fi
if ! (umask 077; set -o noclobber; : >"$log_file"); then
  printf 'Could not safely create log file: %s\n' "$log_file" >&2
  exit 1
fi
exec > >(tee -a "$log_file") 2>&1

printf '\nMigration started at %s\n' "$(date --iso-8601=seconds)"
printf 'Log: %s\n' "$log_file"

completed=0

handle_exit() {
  status=$?
  trap - EXIT ERR INT TERM

  if ((status != 0)); then
    printf 'Migration interrupted after %d completed mapping(s). No source data was deleted. Inspect %s and any *.migrating-%s directories.\n' \
      "$completed" "$log_file" "$timestamp" >&2
  fi

  if ((${#managed_container_units[@]} || ${#managed_host_units[@]})); then
    printf 'Managed services remain stopped for the host-only cutover.\n'
  fi

  exit "$status"
}

trap handle_exit EXIT
trap 'exit 130' INT TERM

if ((${#managed_container_units[@]})); then
  printf 'Stopping services inside the lukasl-dev container; they will remain stopped:\n'
  printf '  - %s\n' "${managed_container_units[@]}"
  if ! container_systemctl stop "${managed_container_units[@]}"; then
    printf 'Could not stop every managed service inside the container.\n' >&2
    exit 1
  fi

  for unit in "${managed_container_units[@]}"; do
    if container_systemctl is-active --quiet "$unit" 2>/dev/null; then
      printf 'Container service is still active after stop: %s\n' "$unit" >&2
      exit 1
    fi
  done
fi

if ((${#managed_host_units[@]})); then
  printf 'Stopping matching host services; they will remain stopped:\n'
  printf '  - %s\n' "${managed_host_units[@]}"
  if ! systemctl stop "${managed_host_units[@]}"; then
    printf 'Could not stop every managed host service.\n' >&2
    exit 1
  fi

  for unit in "${managed_host_units[@]}"; do
    if systemctl is-active --quiet "$unit" 2>/dev/null; then
      printf 'Host service is still active after stop: %s\n' "$unit" >&2
      exit 1
    fi
  done
fi

# DynamicUser state directories can be mounts while their services are active.
# Check only after all writers have been stopped.
for index in "${active_indexes[@]}"; do
  destination="${destinations[$index]}"
  source="$source_root$destination"
  if findmnt --noheadings --mountpoint "$source" >/dev/null 2>&1; then
    printf 'Source is still an active mount point; refusing to cross it: %s\n' "$source" >&2
    exit 1
  fi
  if path_exists "$destination" && findmnt --noheadings --mountpoint "$destination" >/dev/null 2>&1; then
    printf 'Destination is still mounted after stopping services: %s\n' "$destination" >&2
    exit 1
  fi
done

rsync_copy_options=(
  --archive
  --hard-links
  --acls
  --xattrs
  --sparse
  --numeric-ids
)

# --delete is paired with --dry-run here: it only reports unexpected files in
# the temporary copy and can never remove them.
rsync_verify_options=(
  --archive
  --hard-links
  --acls
  --xattrs
  --sparse
  --numeric-ids
  --checksum
  --dry-run
  --delete
  --itemize-changes
)

for index in "${active_indexes[@]}"; do
  destination="${destinations[$index]}"
  source="$source_root$destination"
  backup="$destination.bak-$timestamp"
  temporary="$destination.migrating-$timestamp"
  parent="$(dirname -- "$destination")"

  printf '\n[%d/%d] %s\n' "$((completed + 1))" "${#active_indexes[@]}" "${labels[$index]}"
  printf 'Copying %s -> %s\n' "$source" "$temporary"

  mkdir -p -- "$parent"

  # Recheck immediately before touching this mapping. No pre-existing path is
  # ever reused by rsync.
  if path_exists "$backup" || path_exists "$temporary"; then
    printf 'A backup or temporary path appeared after preflight; aborting.\n' >&2
    exit 1
  fi

  mkdir --mode=0700 -- "$temporary"
  rsync "${rsync_copy_options[@]}" -- "$source/" "$temporary/"

  if ! verification_output="$(rsync "${rsync_verify_options[@]}" -- "$source/" "$temporary/")"; then
    printf 'Verification command failed for %s; partial copy retained at %s\n' \
      "$source" "$temporary" >&2
    exit 1
  fi
  if [[ -n $verification_output ]]; then
    printf 'Verification found differences for %s:\n%s\n' "$source" "$verification_output" >&2
    printf 'Partial copy retained at %s; existing destination was not touched.\n' \
      "$temporary" >&2
    exit 1
  fi

  printf 'Verified copied data for %s\n' "${labels[$index]}"

  if path_exists "$destination"; then
    printf 'Renaming existing destination %s -> %s\n' "$destination" "$backup"
    mv --no-clobber --no-target-directory -- "$destination" "$backup"
    if path_exists "$destination" || ! path_exists "$backup"; then
      printf 'Could not safely back up destination %s; aborting.\n' "$destination" >&2
      exit 1
    fi
  fi

  printf 'Activating %s\n' "$destination"
  mv --no-clobber --no-target-directory -- "$temporary" "$destination"
  if path_exists "$temporary" || ! path_exists "$destination"; then
    printf 'Could not safely activate %s; copied data remains at %s\n' \
      "$destination" "$temporary" >&2
    exit 1
  fi

  completed=$((completed + 1))
done

trap - EXIT ERR INT TERM
printf '\nMigration completed successfully at %s\n' "$(date --iso-8601=seconds)"
printf 'Copied %d state directories. Source data remains at %s\n' "$completed" "$source_root"
printf 'Existing destinations, when present, use suffix .bak-%s\n' "$timestamp"
printf 'Managed services remain stopped. Review ownership, switch to the host-only configuration, then start the new host services.\n'
