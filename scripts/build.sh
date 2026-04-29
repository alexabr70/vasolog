#!/bin/bash
# VasoLog - сборка APK с обязательными тестами
# Запуск: ./scripts/build.sh [release|debug]
set -e

MODE=${1:-debug}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== VasoLog Build (${MODE}) ===${NC}"
echo ""

# 1. Тесты
echo -e "${YELLOW}[1/3] Тестирование...${NC}"
./scripts/test_all.sh
echo ""

# 2. Сборка
echo -e "${YELLOW}[2/3] Сборка APK (${MODE})...${NC}"

# SENTRY_DSN из .env.local (gitignored) или из окружения - для крэш-репортов в Sentry.
# Если не задан - Sentry не активируется (приложение работает без сбора крэшей).
DART_DEFINES=""
if [ -z "${SENTRY_DSN:-}" ] && [ -f ".env.local" ]; then
  # shellcheck disable=SC1091
  set -a; . .env.local; set +a
fi
if [ -n "${SENTRY_DSN:-}" ]; then
  DART_DEFINES="--dart-define=SENTRY_DSN=${SENTRY_DSN}"
  echo "  -> Sentry: enabled"
else
  echo "  -> Sentry: disabled (нет SENTRY_DSN в окружении или .env.local)"
fi

if [ "$MODE" = "release" ]; then
  flutter build apk --release ${DART_DEFINES}
else
  flutter build apk --debug ${DART_DEFINES}
fi

APK_PATH="build/app/outputs/flutter-apk/app-${MODE}.apk"
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)

echo ""

# 3. Аудит безопасности
echo -e "${YELLOW}[3/3] Аудит безопасности...${NC}"
./scripts/security_audit.sh
echo ""

echo -e "${GREEN}=== Сборка завершена ===${NC}"
echo -e "APK: ${APK_PATH} (${APK_SIZE})"
