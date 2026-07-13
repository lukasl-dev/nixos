#!/usr/bin/env bash
set -Eeuo pipefail

readonly container_name="lukasl-dev"
readonly source_dir="/var/lib/nixos-containers/$container_name"
readonly safety_margin_bytes=$((64 * 1024 * 1024))

backup_dir="${1:-$HOME/nixos-container-backups}"

usage() {
  cat <<EOF
Usage: $0 [BACKUP_DIRECTORY]

Creates and verifies a complete archive of:
  $source_dir

The container is stopped before archiving and deliberately left stopped for the
state migration. The source directory is never modified or deleted.

Default backup directory:
  $HOME/nixos-container-backups
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if (($# > 1)); then
  usage >&2
  exit 2
fi

if [[ $EUID -eq 0 ]]; then
  printf 'Run this script as your regular user. It invokes sudo where necessary.\n' >&2
  exit 1
fi

for command in awk date df du gzip mv sha256sum sudo tar; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Required command is unavailable: %s\n' "$command" >&2
    exit 1
  fi
done

if ! command -v nixos-container >/dev/null 2>&1; then
  printf 'Required command is unavailable: nixos-container\n' >&2
  exit 1
fi

mkdir -p -- "$backup_dir"
backup_dir="$(cd -- "$backup_dir" && pwd -P)"

if [[ ! -w $backup_dir ]]; then
  printf 'Backup directory is not writable: %s\n' "$backup_dir" >&2
  exit 1
fi

# Authenticate before doing preflight work, rather than prompting halfway
# through the safety procedure.
sudo -v

if ! sudo test -d "$source_dir"; then
  printf 'Container data directory does not exist: %s\n' "$source_dir" >&2
  exit 1
fi
if sudo test -L "$source_dir"; then
  printf 'Refusing to archive a symlink as the container root: %s\n' "$source_dir" >&2
  exit 1
fi

source_bytes="$(sudo du \
  --summarize \
  --apparent-size \
  --block-size=1 \
  -- "$source_dir" | awk '{print $1}')"
available_bytes="$(df --block-size=1 --output=avail -- "$backup_dir" | awk 'NR == 2 {print $1}')"
required_bytes=$((source_bytes + source_bytes / 10 + safety_margin_bytes))

printf 'Container data:       %s bytes\n' "$source_bytes"
printf 'Backup space:         %s bytes available\n' "$available_bytes"
printf 'Conservative minimum: %s bytes\n' "$required_bytes"

if ((available_bytes < required_bytes)); then
  printf 'Insufficient free space in %s; no files were changed.\n' "$backup_dir" >&2
  exit 1
fi

if ! container_status="$(sudo nixos-container status "$container_name")"; then
  printf 'Could not determine the container status; refusing to continue.\n' >&2
  exit 1
fi
case "${container_status,,}" in
  up)
    printf 'Stopping container %s for a consistent archive...\n' "$container_name"
    sudo nixos-container stop "$container_name"
    ;;
  down)
    ;;
  *)
    printf 'Unexpected container status %q; refusing to continue.\n' "$container_status" >&2
    exit 1
    ;;
esac

if ! container_status="$(sudo nixos-container status "$container_name")"; then
  printf 'Could not verify that the container stopped.\n' >&2
  exit 1
fi
if [[ ${container_status,,} != "down" ]]; then
  printf 'Container status is %q, not down; refusing to archive live state.\n' "$container_status" >&2
  exit 1
fi

readonly timestamp="$(date -u +'%Y%m%dT%H%M%S.%NZ')"
archive="$backup_dir/$container_name-$timestamp.tar.gz"
partial="$archive.partial"
checksum="$archive.sha256"

for path in "$archive" "$partial" "$checksum"; do
  if [[ -e $path || -L $path ]]; then
    printf 'Refusing to overwrite existing path: %s\n' "$path" >&2
    exit 1
  fi
done

archive_completed=false
report_failure() {
  status=$?
  trap - EXIT INT TERM

  if ((status != 0)); then
    printf '\nBackup failed. The source data was not modified.\n' >&2
    if [[ -e $partial ]]; then
      printf 'The incomplete archive was retained for inspection:\n  %s\n' "$partial" >&2
    fi
    printf 'The container remains stopped.\n' >&2
  elif ! $archive_completed; then
    printf '\nBackup did not reach its completion marker. Inspect %s\n' "$backup_dir" >&2
  fi

  exit "$status"
}
trap report_failure EXIT
trap 'exit 130' INT TERM

printf 'Creating archive without overwriting any existing file...\n'
umask 077
set -o noclobber
sudo tar \
  --acls \
  --xattrs \
  --xattrs-include='*' \
  --numeric-owner \
  --sparse \
  --directory=/var/lib/nixos-containers \
  --create \
  --file=- \
  "$container_name" |
  gzip -1 >"$partial"

printf 'Testing compressed archive integrity...\n'
gzip --test -- "$partial"

# Promote the verified partial archive without allowing mv to replace a path
# that appeared after preflight.
mv --no-clobber --no-target-directory -- "$partial" "$archive"
if [[ -e $partial || ! -f $archive ]]; then
  printf 'Could not safely promote the verified archive to %s\n' "$archive" >&2
  exit 1
fi

printf 'Writing SHA-256 checksum...\n'
(
  cd -- "$backup_dir"
  sha256sum -- "${archive##*/}" >"${checksum##*/}"
  sha256sum --check -- "${checksum##*/}"
)

archive_completed=true
trap - EXIT INT TERM

printf '\nBackup completed and verified.\n'
printf 'Archive:  %s\n' "$archive"
printf 'Checksum: %s\n' "$checksum"
printf 'Container %s remains stopped.\n' "$container_name"
printf '\nYou can now run the migration dry run:\n'
printf '  sudo ./scripts/migrate-galaxy-state.sh --dry-run\n'
