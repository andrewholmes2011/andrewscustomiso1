#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
IMAGE_NAME="Andrew-OS-amd64.iso"
LOG_FILE="$ROOT_DIR/build.log"

log() { printf '\n\033[1;36m[Andrew OS]\033[0m %s\n' "$*"; }
fail() { printf '\n\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

if [[ "$(dpkg --print-architecture 2>/dev/null || true)" != "amd64" ]]; then
  fail "Build on an amd64 Debian host. Cross-architecture builds are not configured."
fi
if [[ $EUID -ne 0 ]]; then
  fail "Run with sudo: sudo ./build.sh"
fi
if ! command -v lb >/dev/null 2>&1; then
  fail "live-build is missing. Install prerequisites with: sudo apt install live-build"
fi
if [[ ! -d "$ROOT_DIR/config/package-lists" || ! -f "$ROOT_DIR/config/package-lists/andrew-os.list.chroot" ]]; then
  fail "The live-build config directory is missing or incomplete."
fi

mkdir -p "$DIST_DIR"
cd "$ROOT_DIR"

export DEBIAN_FRONTEND=noninteractive
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(date -u +%s)}"

log "Preparing Debian 13 (Trixie) live-build configuration"
# Recreate generated live-build state so stale local settings cannot leak into a build.
rm -f config/binary config/bootstrap config/chroot config/common config/source
lb config \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free-firmware" \
  --binary-image iso-hybrid \
  --debian-installer live \
  --debian-installer-gui true \
  --apt-recommends true \
  --firmware-binary true \
  --firmware-chroot true \
  --memtest none \
  --iso-application "Andrew OS" \
  --iso-publisher "Andrew OS Project" \
  --iso-volume "ANDREW_OS" \
  --bootappend-live "boot=live components username=andrew hostname=andrew-os locales=en_US.UTF-8 keyboard-layouts=us quiet splash" \
  --uefi-secure-boot auto

log "Building the live image. This downloads Debian packages and may take a while."
if ! lb build 2>&1 | tee "$LOG_FILE"; then
  fail "live-build failed. Review $LOG_FILE for the first package or configuration error."
fi

BUILT_IMAGE="$ROOT_DIR/live-image-amd64.hybrid.iso"
if [[ ! -s "$BUILT_IMAGE" ]]; then
  fail "Build command completed but $BUILT_IMAGE was not created."
fi

install -m 0644 "$BUILT_IMAGE" "$DIST_DIR/$IMAGE_NAME"
sha256sum "$DIST_DIR/$IMAGE_NAME" > "$DIST_DIR/$IMAGE_NAME.sha256"
log "Build finished."
printf 'ISO: %s\n' "$DIST_DIR/$IMAGE_NAME"
printf 'SHA256: %s\n' "$DIST_DIR/$IMAGE_NAME.sha256"
