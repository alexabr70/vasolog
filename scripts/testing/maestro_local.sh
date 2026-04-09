#!/bin/bash
# Локальный прогон Maestro flows на подключённом устройстве
# Usage: ./scripts/testing/maestro_local.sh [flow_name]
# Default: все flows из .maestro/

set -e

cd "$(dirname "$0")/../.."

MAESTRO="${MAESTRO:-/d/dev/tools/maestro/bin/maestro.bat}"
if [[ ! -f "$MAESTRO" ]]; then
  MAESTRO=$(which maestro 2>/dev/null || echo "")
fi

if [[ -z "$MAESTRO" ]]; then
  echo "ERROR: maestro не найден. Установи: https://maestro.mobile.dev/"
  exit 1
fi

# Проверить что устройство подключено
ADB="${ADB:-/d/dev/AndroidSDK/platform-tools/adb.exe}"
[[ ! -x "$ADB" ]] && ADB=$(which adb)
DEVICES=$("$ADB" devices | grep -c "device$" || true)
if [[ "$DEVICES" -eq 0 ]]; then
  echo "ERROR: устройство не подключено. Запусти scripts/testing/adb_check.sh"
  exit 1
fi

FLOW="${1:-.maestro/}"

echo "=== Запуск Maestro: $FLOW ==="
mkdir -p maestro-reports

"$MAESTRO" test \
  --format junit \
  --output "maestro-reports/report.xml" \
  "$FLOW"

echo ""
echo "=== Артефакты в ~/.maestro/tests/ ==="
MAESTRO_LOG_DIR="$HOME/.maestro/tests"
if [[ -d "$MAESTRO_LOG_DIR" ]]; then
  LATEST=$(ls -td "$MAESTRO_LOG_DIR"/*/ 2>/dev/null | head -1)
  echo "Последний прогон: $LATEST"
  ls -la "$LATEST" 2>/dev/null | head -20
fi
