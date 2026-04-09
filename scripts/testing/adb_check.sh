#!/bin/bash
# Проверка ADB подключения к устройству
# Usage: ./scripts/testing/adb_check.sh

set -e

ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"

if [[ ! -x "$ADB" ]]; then
  ADB=$(which adb 2>/dev/null || echo "")
  if [[ -z "$ADB" ]]; then
    echo "ERROR: adb не найден. Установи Android SDK platform-tools."
    exit 1
  fi
fi

echo "=== ADB версия ==="
"$ADB" version | head -2

echo ""
echo "=== Подключённые устройства ==="
"$ADB" devices -l

DEVICE_COUNT=$("$ADB" devices | grep -c "device$" || true)

if [[ "$DEVICE_COUNT" -eq 0 ]]; then
  echo ""
  echo "WARNING: устройств не найдено"
  echo ""
  echo "Чтобы подключить Android телефон:"
  echo "1. Settings -> About phone -> тапнуть 'Build number' 7 раз (Developer mode)"
  echo "2. Settings -> System -> Developer options -> USB debugging = ON"
  echo "3. Подключить USB кабель к ПК"
  echo "4. На телефоне появится диалог 'Allow USB debugging?' -> Allow + галочка"
  echo ""
  echo "Для Huawei EMUI:"
  echo "  - Build number 7 раз в 'About phone'"
  echo "  - USB debugging в Developer options"
  echo "  - USB configuration: MTP (File transfer)"
  exit 1
fi

echo ""
echo "OK: $DEVICE_COUNT устройство(а) подключено"

# Инфо о первом устройстве
DEVICE_ID=$("$ADB" devices | grep "device$" | head -1 | awk '{print $1}')
echo ""
echo "=== Инфо об устройстве $DEVICE_ID ==="
echo "Модель:   $("$ADB" -s "$DEVICE_ID" shell getprop ro.product.model)"
echo "Brand:    $("$ADB" -s "$DEVICE_ID" shell getprop ro.product.brand)"
echo "Android:  $("$ADB" -s "$DEVICE_ID" shell getprop ro.build.version.release)"
echo "SDK:      $("$ADB" -s "$DEVICE_ID" shell getprop ro.build.version.sdk)"
echo "ABI:      $("$ADB" -s "$DEVICE_ID" shell getprop ro.product.cpu.abi)"
