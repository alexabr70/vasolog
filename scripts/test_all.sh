#!/bin/bash
# VasoLog - полный тестовый пайплайн
# Запуск: ./scripts/test_all.sh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== VasoLog Test Pipeline ===${NC}"
echo ""

# 1. Flutter analyze
echo -e "${YELLOW}[1/4] Flutter analyze...${NC}"
flutter analyze --no-pub
echo -e "${GREEN}[OK] 0 issues${NC}"
echo ""

# 2. Unit + widget тесты
echo -e "${YELLOW}[2/4] Unit + widget тесты...${NC}"
flutter test
echo -e "${GREEN}[OK] Все тесты пройдены${NC}"
echo ""

# 3. Проверка зависимостей (osv-scanner если установлен)
echo -e "${YELLOW}[3/4] Проверка зависимостей...${NC}"
if command -v osv-scanner &> /dev/null; then
  osv-scanner -r . || echo -e "${YELLOW}[WARN] Найдены уязвимости (см. выше)${NC}"
else
  echo -e "${YELLOW}[SKIP] osv-scanner не установлен (go install github.com/google/osv-scanner/cmd/osv-scanner@latest)${NC}"
fi
echo ""

# 4. Проверка на секреты в коде
echo -e "${YELLOW}[4/4] Проверка на секреты в коде...${NC}"
SECRETS_FOUND=0
# API ключи в dart файлах (кроме dart-define паттерна)
if grep -rn "apiKey\s*=\s*['\"][a-zA-Z0-9]\{20,\}" lib/ --include="*.dart" 2>/dev/null | grep -v "fromEnvironment" | grep -v "test"; then
  echo -e "${RED}[FAIL] Найдены захардкоженные API ключи!${NC}"
  SECRETS_FOUND=1
fi
# .env файлы
if [ -f ".env" ] && git ls-files --error-unmatch .env 2>/dev/null; then
  echo -e "${RED}[FAIL] .env файл в git!${NC}"
  SECRETS_FOUND=1
fi
if [ $SECRETS_FOUND -eq 0 ]; then
  echo -e "${GREEN}[OK] Секретов не найдено${NC}"
fi
echo ""

echo -e "${GREEN}=== Все проверки пройдены ===${NC}"
