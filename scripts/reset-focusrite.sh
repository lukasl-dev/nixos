#!/usr/bin/env bash
set -euo pipefail

vendor_id="${1:-1235}"
product_id="${2:-8219}"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "Run as root (use sudo)." >&2
    exit 1
fi

matched=0

for device in /sys/bus/usb/devices/*; do
    [[ -f "$device/idVendor" && -f "$device/idProduct" ]] || continue
    [[ -w "$device/authorized" ]] || continue

    if [[ "$(<"$device/idVendor")" == "$vendor_id" && "$(<"$device/idProduct")" == "$product_id" ]]; then
        matched=1
        echo "Resetting USB device at $device (${vendor_id}:${product_id})"
        echo 0 > "$device/authorized"
        sleep 1
        echo 1 > "$device/authorized"
    fi
done

if [[ $matched -eq 0 ]]; then
    echo "No matching USB device found for ${vendor_id}:${product_id}" >&2
    exit 1
fi

echo "Done. Check with: wpctl status"
