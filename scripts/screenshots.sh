#!/usr/bin/env bash
# Replaces the README screenshots Glance.png, View*.png and Menu.png with the app
# on the white fenix 7S, taken with live data in the simulator of the pinned
# Docker image.
#
# Usage: scripts/screenshots.sh
set -euo pipefail

cd "$(dirname "$0")/.."
source scripts/toolchain.env
source scripts/docker.sh

SCREENSHOT_DEVICE=fenix7s

docker_available || {
  echo "ERROR: screenshots need Docker, natively or inside WSL." >&2
  exit 1
}
echo "Taking screenshots on $SCREENSHOT_DEVICE"
run_image --entrypoint python3 "$CONNECTIQ_IMAGE" \
  scripts/simulator_screenshots.py "$SCREENSHOT_DEVICE" .
echo "Screenshots ready: Glance.png View.png ViewDay.png ViewDays.png Menu.png"
