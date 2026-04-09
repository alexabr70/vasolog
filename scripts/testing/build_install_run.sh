#!/bin/bash
# Полный цикл: build -> install -> launch -> logcat
# Usage: ./scripts/testing/build_install_run.sh [debug|release]

set -e

BUILD_TYPE="${1:-debug}"
ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
PACKAGE="com.vasolog.vasolog"
ACTIVITY="com.vasolog.vasolog.MainActivity"

if [[ ! -x "$ADB" ]]; then
  ADB=$(which adb 2>/dev/null)
fi

cd "$(dirname "$0")/../.."

echo "=== 1. Flutter build APK ($BUILD_TYPE) ==="
flutter build apk --"$BUILD_TYPE"

APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
if [[ ! -f "$APK_PATH" ]]; then
  echo "ERROR: APK не собрался: $APK_PATH"
  exit 1
fi
echo "APK готов: $APK_PATH ($(du -h "$APK_PATH" | cut -f1))"

echo ""
echo "=== 2. Install на устройство ==="
"$ADB" install -r "$APK_PATH"

echo ""
echo "=== 3. Launch приложения ==="
"$ADB" shell am start -n "$PACKAGE/$ACTIVITY"

echo ""
echo "=== 4. Очистка logcat ==="
"$ADB" logcat -c

echo ""
echo "=== 5. Tail logcat (Ctrl+C для выхода) ==="
"$ADB" logcat -v time | grep -iE "flutter|vasolog|$PACKAGE|AndroidRuntime|FATAL"
