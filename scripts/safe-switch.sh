#!/usr/bin/env bash
set -euo pipefail

available_mem_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

limit_kb=$(( available_mem_kb * 90 / 100 ))
limit_bytes=$(( limit_kb * 1024 ))

total_cores=$(nproc)
cpus=""

if [ "$total_cores" -gt 4 ]; then
    # Exclude cores 0 and 1 for system responsiveness
    last_core=$(( total_cores - 1 ))
    cpus=$(seq -s, 2 $last_core)
elif [ "$total_cores" -gt 1 ]; then
    # Exclude core 0
    last_core=$(( total_cores - 1 ))
    cpus=$(seq -s, 1 $last_core)
else
    # Single core, use it
    cpus="0"
fi

echo "Safe-switch: limiting to $((limit_kb / 1024)) MB RAM and CPUs: $cpus"

flake_path=$(pwd)

exec sudo systemd-run --scope --quiet \
    --property=MemoryMax="${limit_bytes}" \
    --property=AllowedCPUs="$cpus" \
    nh os switch -R "$@" "$flake_path"

