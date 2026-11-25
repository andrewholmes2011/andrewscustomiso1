#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"
if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo ./clean.sh" >&2
  exit 1
fi
lb clean --purge
rm -f "$ROOT_DIR/live-image-amd64.hybrid.iso" "$ROOT_DIR/build.log"
echo "Generated live-build state and local ISO output removed. Source configuration was preserved."
