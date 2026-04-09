#!/bin/bash
# Скриншот с устройства в локальную папку
# Usage: ./scripts/testing/screenshot.sh [имя_файла_без_расширения]

set -e

ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
if [[ ! -x "$ADB" ]]; then
  ADB=$(which adb)
fi

cd "$(dirname "$0")/../.."

NAME="${1:-screen_$(date +%Y%m%d_%H%M%S)}"
mkdir -p screenshots
OUT="screenshots/${NAME}.png"

"$ADB" exec-out screencap -p > "$OUT"

if [[ -s "$OUT" ]]; then
  SIZE=$(du -h "$OUT" | cut -f1)
  echo "OK: $OUT ($SIZE)"
else
  echo "ERROR: скриншот не снят"
  exit 1
fi
