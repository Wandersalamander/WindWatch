#!/usr/bin/env bash
# Runs "docker run <arguments>" inside WSL with a copy of the repository at /app,
# see scripts/docker.sh. Docker reads the Windows drive about 5 times slower than
# the WSL filesystem, so it works on a copy and the files it writes are copied back.
set -euo pipefail

copy=$(mktemp -d)
# ponytail: files the container writes as root stay behind for a non-root WSL user
trap 'rm -rf "$copy" 2>/dev/null || true' EXIT
tar -c --exclude=./.git --exclude='./bin/*' . | tar -C "$copy" -x
touch "$copy/.copied"

docker run --rm -v "$copy:/app" -w /app "$@"

(cd "$copy" && find . -type f -newer .copied -print0 | tar -c --null -T -) | tar -x
