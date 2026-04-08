#!/bin/bash
# VasoLog - сборка APK с обязательными тестами
# Запуск: ./scripts/build.sh [release|debug]
set -e

MODE=${1:-debug}
API_KEY="963fe87900f276da9f0957b422accfea"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== VasoLog Build (${MODE}) ===${NC}"
echo ""

# Запускаем тесты
echo -e "${YELLOW}[1/2] Тестирование...${NC}"
./scripts/test_all.sh
echo ""

# Сборка
echo -e "${YELLOW}[2/2] Сборка APK (${MODE})...${NC}"
if [ "$MODE" = "release" ]; then
  flutter build apk --release --dart-define=WEATHER_API_KEY=$API_KEY
else
  flutter build apk --debug --dart-define=WEATHER_API_KEY=$API_KEY
fi

APK_PATH="build/app/outputs/flutter-apk/app-${MODE}.apk"
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)

echo ""
echo -e "${GREEN}=== Сборка завершена ===${NC}"
echo -e "APK: ${APK_PATH} (${APK_SIZE})"
