#!/usr/bin/env bash
set -euo pipefail

available_mem_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

limit_kb=$(( available_mem_kb * 90 / 100 ))
limit_bytes=$(( limit_kb * 1024 ))

total_cores=$(nproc)
cpus=""

# Use the upper half of cores to leave lower cores available for system responsiveness
cores_to_use=$(( total_cores / 2 ))
if [ "$cores_to_use" -lt 1 ]; then
    cores_to_use=1
fi

start_core=$(( total_cores - cores_to_use ))
last_core=$(( total_cores - 1 ))
cpus=$(seq -s, $start_core $last_core)

echo "Safe-switch: limiting to $((limit_kb / 1024)) MB RAM and CPUs: $cpus"

flake_path=$(pwd)

exec sudo systemd-run --scope --quiet \
    --property=MemoryMax="${limit_bytes}" \
    --property=AllowedCPUs="$cpus" \
    nh os switch -R "$@" "$flake_path"

