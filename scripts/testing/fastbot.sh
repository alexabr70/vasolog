#!/bin/bash
# Fastbot (ByteDance) - автономное UI exploration
# Находит краши и ANR в 10x лучше чем monkey
# https://github.com/bytedance/Fastbot_Android
#
# Usage: ./scripts/testing/fastbot.sh [duration_minutes]
# Default: 10 минут

set -e

DURATION_MINUTES="${1:-10}"
ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
PACKAGE="com.vasolog.app"
FASTBOT_DIR="/d/dev/tools/fastbot"

if [[ ! -x "$ADB" ]]; then
  ADB=$(which adb)
fi

# Скачать Fastbot jars если их нет
if [[ ! -f "$FASTBOT_DIR/fastbot-thirdpart.jar" ]]; then
  echo "Fastbot не найден. Скачиваю..."
  mkdir -p "$FASTBOT_DIR"
  cd "$FASTBOT_DIR"
  BASE="https://github.com/bytedance/Fastbot_Android/raw/main/fastbot-mobile"
  curl -sL -o monkeyq.jar "$BASE/monkeyq.jar"
  curl -sL -o framework.jar "$BASE/framework.jar"
  curl -sL -o fastbot-thirdpart.jar "$BASE/fastbot-thirdpart.jar"
  curl -sL -o libs.zip "$BASE/libs.zip" 2>/dev/null || true
  cd -
fi

echo "=== Push Fastbot jars на устройство ==="
"$ADB" push "$FASTBOT_DIR/monkeyq.jar" /sdcard/
"$ADB" push "$FASTBOT_DIR/framework.jar" /sdcard/
"$ADB" push "$FASTBOT_DIR/fastbot-thirdpart.jar" /sdcard/

echo ""
echo "=== Запуск Fastbot на $DURATION_MINUTES минут ==="
echo "(граф навигации, поиск крашей и ANR)"

mkdir -p fastbot-output
"$ADB" logcat -c

"$ADB" shell "CLASSPATH=/sdcard/monkeyq.jar:/sdcard/framework.jar:/sdcard/fastbot-thirdpart.jar exec app_process /system/bin com.android.commands.monkey.Monkey -p $PACKAGE --agent reuseq --running-minutes $DURATION_MINUTES --throttle 500 -v -v" 2>&1 | tee fastbot-output/fastbot.log

"$ADB" logcat -d > fastbot-output/logcat.txt

echo ""
echo "=== Поиск крашей в логах ==="
if grep -E "FATAL EXCEPTION|CRASH|ANR in $PACKAGE" fastbot-output/logcat.txt; then
  echo ""
  echo "!!! НАЙДЕНЫ КРАШИ !!!"
  exit 1
else
  echo "OK: крашей не найдено"
fi
