#!/bin/bash
# Беспроводное подключение к Huawei Pura 70 Pro через ADB
#
# Usage:
#   Первый раз: ./wireless_connect.sh pair <IP:PORT> <CODE>
#   Потом:      ./wireless_connect.sh connect <IP:PORT>
#   Отключить:  ./wireless_connect.sh disconnect
#   Статус:     ./wireless_connect.sh (без аргументов)
#
# На телефоне:
#   Settings -> System -> Developer options -> Wireless debugging -> ON
#   "Pair device with pairing code" - получаем IP:PORT и 6-значный код
#   Для последующих подключений - используй IP:PORT из главного экрана Wireless debugging

set -e

ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
if [[ ! -x "$ADB" ]]; then
  ADB=$(which adb)
fi

CMD="${1:-status}"

case "$CMD" in
  pair)
    ADDR="${2:?'IP:PORT required'}"
    CODE="${3:?'pairing code required'}"
    echo "=== Pairing $ADDR с кодом $CODE ==="
    echo "$CODE" | "$ADB" pair "$ADDR"
    ;;
  connect)
    ADDR="${2:?'IP:PORT required'}"
    echo "=== Connecting to $ADDR ==="
    "$ADB" connect "$ADDR"
    "$ADB" devices
    ;;
  disconnect)
    "$ADB" disconnect
    echo "OK: все беспроводные сессии отключены"
    ;;
  tcpip)
    # Запуск tcpip через USB - один раз надо кабель
    PORT="${2:-5555}"
    echo "=== Переключаю USB -> TCP:$PORT ==="
    "$ADB" tcpip "$PORT"
    echo "Теперь отключи кабель и запусти:"
    echo "  $0 connect <phone_ip>:$PORT"
    ;;
  status)
    "$ADB" devices
    ;;
  *)
    echo "Unknown command: $CMD"
    echo "Usage: $0 {pair|connect|disconnect|tcpip|status}"
    exit 1
    ;;
esac
