#!/usr/bin/env bash
set -euo pipefail

unit="gsr-three-hours"
duration="3h"
monitor="DP-1"
record_dir="$HOME/Videos/Recordings"
output="$record_dir/recording-$(date +%F_%H-%M-%S).mkv"
kms_wrapper="/run/wrappers/bin/gsr-kms-server"

if [[ ! -x "$kms_wrapper" ]]; then
  cat >&2 <<'EOF'
GPU Screen Recorder's KMS capability wrapper is not installed.
Rebuild the edited NixOS configuration first, then run this script again.
EOF
  exit 1
fi

if systemctl --user is-active --quiet "$unit.service"; then
  echo "A recording is already running: $unit.service" >&2
  echo "Check it with: systemctl --user status $unit.service" >&2
  exit 1
fi

mkdir -p "$record_dir"
systemctl --user reset-failed "$unit.service" 2>/dev/null || true

systemd-run --user \
  --unit="$unit" \
  --description="Three-hour screen recording" \
  --property=Type=exec \
  "$(command -v systemd-inhibit)" \
    --what=sleep:idle \
    --mode=block \
    --who="GPU Screen Recorder" \
    --why="Three-hour screen recording" \
  "$(command -v timeout)" \
    --foreground \
    --signal=INT \
    --kill-after=30s \
    "$duration" \
  "$(command -v gpu-screen-recorder)" \
    -w "$monitor" \
    -f 60 \
    -q very_high \
    -a default_output \
    -c mkv \
    -o "$output"

# Catch immediate setup failures instead of claiming that recording started.
sleep 2
if ! systemctl --user is-active --quiet "$unit.service"; then
  echo "Recording failed to start. Recent logs:" >&2
  journalctl --user -u "$unit.service" -n 30 --no-pager >&2
  exit 1
fi

printf '\nRecording %s with desktop audio for %s.\n' "$monitor" "$duration"
printf 'Recording to: %s\n' "$output"
printf 'Status:       systemctl --user status %s.service\n' "$unit"
printf 'Follow logs:  journalctl --user -fu %s.service\n' "$unit"
printf 'Stop early:   systemctl --user kill --signal=SIGINT %s.service\n' "$unit"
