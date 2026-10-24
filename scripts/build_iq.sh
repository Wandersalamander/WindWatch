#!/usr/bin/env bash
# Builds the store package bin/LakeWind.iq for every device in manifest.xml,
# with the same toolchain as CI (scripts/toolchain.env). Fails on compiler warnings.
# Then updates the README screenshots, see scripts/screenshots.sh.
#
# Usage: scripts/build_iq.sh <developer_key.der>
#
# Uses Docker when available, natively or inside WSL (identical to CI), otherwise
# the locally installed SDK, which must then match CONNECTIQ_SDK_VERSION exactly.
set -euo pipefail

cd "$(dirname "$0")/.."
source scripts/toolchain.env
source scripts/docker.sh

OUTPUT=bin/LakeWind.iq
BUILD_LOG=bin/build.log
COMPILER_ARGS="-e -r -w -l 3 -f monkey.jungle -o $OUTPUT"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

check_key() {
  [[ -n ${1:-} ]] || fail "missing developer key.
  Usage: $0 <developer_key.der>
  The store only accepts updates signed with the key of the first upload, so reuse
  your existing key. Only for a first upload, create one with:
    openssl genrsa -out developer_key.pem 4096
    openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
  and back it up outside this repository."
  [[ -f $1 ]] || fail "developer key '$1' not found."
}

local_connectiq_home() {
  if [[ -n ${APPDATA:-} ]]; then
    echo "$APPDATA/Garmin/ConnectIQ"
  elif [[ $(uname) == Darwin ]]; then
    echo "$HOME/Library/Application Support/Garmin/ConnectIQ"
  else
    echo "$HOME/.Garmin/ConnectIQ"
  fi
}

find_local_monkeyc() {
  local connectiq_home sdk_dir
  connectiq_home=$(local_connectiq_home)
  sdk_dir=$(find "$connectiq_home/Sdks" -maxdepth 1 -name "connectiq-sdk-*-$CONNECTIQ_SDK_VERSION-*" 2>/dev/null | head -1)
  [[ -n $sdk_dir ]] || fail "Connect IQ SDK $CONNECTIQ_SDK_VERSION not found in '$connectiq_home/Sdks'.
  Installed: $(ls "$connectiq_home/Sdks" 2>/dev/null | tr '\n' ' ')
  Install exactly $CONNECTIQ_SDK_VERSION with the SDK Manager (https://developer.garmin.com/connect-iq/sdk/),
  or install Docker to build with the CI image $CONNECTIQ_IMAGE."
  if [[ -f $sdk_dir/bin/monkeyc.bat ]]; then
    echo "$sdk_dir/bin/monkeyc.bat"
  else
    echo "$sdk_dir/bin/monkeyc"
  fi
}

check_local_devices() {
  local devices_dir missing
  devices_dir="$(local_connectiq_home)/Devices"
  missing=$(grep -o '<iq:product id="[^"]*"' manifest.xml | cut -d'"' -f2 |
    while read -r device; do [[ -d $devices_dir/$device ]] || echo "$device"; done)
  [[ -z $missing ]] || fail "device files missing in '$devices_dir' for: $(echo $missing).
  Download them in the SDK Manager under 'Devices'."
}

check_java() {
  command -v java >/dev/null || fail "Java not found. monkeyc needs a Java runtime (17 or newer) on PATH."
}

# The key is mounted on its own, as it is usually kept outside the repository
build_with_docker() {
  local key_dir
  key_dir=$(cd "$(dirname "$1")" && pwd)
  echo "Building with Docker image $CONNECTIQ_IMAGE (SDK $CONNECTIQ_SDK_VERSION)"
  run_image -v "$(docker_path "$key_dir"):/key:ro" --entrypoint monkeyc \
    "$CONNECTIQ_IMAGE" $COMPILER_ARGS -y "/key/$(basename "$1")"
}

build_with_local_sdk() {
  local monkeyc
  monkeyc=$(find_local_monkeyc)
  check_java
  check_local_devices
  echo "Building with local SDK $monkeyc"
  "$monkeyc" $COMPILER_ARGS -y "$1"
}

check_build_log() {
  if grep -E '^(ERROR|WARNING)' "$BUILD_LOG"; then
    fail "compiler reported the errors or warnings above."
  fi
  grep -q 'BUILD SUCCESSFUL' "$BUILD_LOG" || fail "build did not succeed, see $BUILD_LOG."
}

check_key "${1:-}"
mkdir -p bin
if docker_available; then
  build_with_docker "$1" | tee "$BUILD_LOG"
else
  build_with_local_sdk "$1" | tee "$BUILD_LOG"
fi
check_build_log
echo "Store package ready: $OUTPUT"
if docker_available; then
  scripts/screenshots.sh
else
  echo "Skipped the screenshots, they need Docker."
fi
