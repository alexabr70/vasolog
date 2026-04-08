#!/bin/bash
# VasoLog - аудит безопасности APK
# Запуск: ./scripts/security_audit.sh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APK="build/app/outputs/flutter-apk/app-debug.apk"
AAPT="D:/dev/AndroidSDK/build-tools/36.1.0/aapt"
ISSUES=0

echo -e "${YELLOW}=== VasoLog Security Audit ===${NC}"
echo ""

# 1. Проверка что APK существует
if [ ! -f "$APK" ]; then
  echo -e "${RED}[FAIL] APK не найден: $APK${NC}"
  echo "Сначала: ./scripts/build.sh"
  exit 1
fi

# 2. Debug flag (в release сборке не должно быть)
echo -e "${YELLOW}[1/7] Debug flag...${NC}"
if $AAPT dump badging "$APK" 2>/dev/null | grep -q "application-debuggable"; then
  if echo "$APK" | grep -q "debug"; then
    echo -e "${YELLOW}[WARN] Debug APK (ожидаемо для debug сборки)${NC}"
  else
    echo -e "${RED}[FAIL] Release APK помечен как debuggable!${NC}"
    ISSUES=$((ISSUES+1))
  fi
else
  echo -e "${GREEN}[OK] Не debuggable${NC}"
fi

# 3. Permissions аудит
echo -e "${YELLOW}[2/7] Permissions...${NC}"
PERMS=$($AAPT dump permissions "$APK" 2>/dev/null)
DANGEROUS_UNUSED=""
# Проверяем что нет лишних опасных permissions
for perm in READ_CONTACTS WRITE_CONTACTS READ_CALL_LOG SEND_SMS READ_SMS RECORD_AUDIO READ_EXTERNAL_STORAGE WRITE_EXTERNAL_STORAGE READ_PHONE_STATE; do
  if echo "$PERMS" | grep -q "$perm"; then
    DANGEROUS_UNUSED="$DANGEROUS_UNUSED $perm"
  fi
done
if [ -n "$DANGEROUS_UNUSED" ]; then
  echo -e "${RED}[FAIL] Ненужные опасные permissions:$DANGEROUS_UNUSED${NC}"
  ISSUES=$((ISSUES+1))
else
  echo -e "${GREEN}[OK] Только необходимые permissions${NC}"
fi

# 4. Минимальный SDK
echo -e "${YELLOW}[3/7] SDK versions...${NC}"
MIN_SDK=$($AAPT dump badging "$APK" 2>/dev/null | grep "sdkVersion" | head -1 | grep -o "[0-9]*")
TARGET_SDK=$($AAPT dump badging "$APK" 2>/dev/null | grep "targetSdkVersion" | head -1 | grep -o "[0-9]*")
echo "  minSdk: $MIN_SDK, targetSdk: $TARGET_SDK"
if [ "$TARGET_SDK" -lt 34 ]; then
  echo -e "${RED}[FAIL] targetSdk < 34 (Google Play требует >= 34)${NC}"
  ISSUES=$((ISSUES+1))
else
  echo -e "${GREEN}[OK] targetSdk=$TARGET_SDK (>= 34)${NC}"
fi

# 5. Секреты в коде
echo -e "${YELLOW}[4/7] Секреты в исходниках...${NC}"
SECRETS=0
if grep -rn "apiKey\s*=\s*['\"][a-zA-Z0-9]\{20,\}" lib/ --include="*.dart" 2>/dev/null | grep -v "fromEnvironment"; then
  echo -e "${RED}[FAIL] Hardcoded API ключи в lib/!${NC}"
  SECRETS=1
fi
if grep -rn "password\s*=\s*['\"]" lib/ --include="*.dart" 2>/dev/null; then
  echo -e "${RED}[FAIL] Hardcoded пароли!${NC}"
  SECRETS=1
fi
if [ $SECRETS -eq 0 ]; then
  echo -e "${GREEN}[OK] Секреты не найдены${NC}"
else
  ISSUES=$((ISSUES+1))
fi

# 6. Hive encryption check
echo -e "${YELLOW}[5/7] Шифрование данных...${NC}"
if grep -q "HiveAesCipher\|encryptionCipher\|flutter_secure_storage" lib/services/storage_service.dart 2>/dev/null; then
  echo -e "${GREEN}[OK] Hive шифрование включено${NC}"
else
  echo -e "${RED}[FAIL] Данные НЕ зашифрованы!${NC}"
  ISSUES=$((ISSUES+1))
fi

# 7. Network security
echo -e "${YELLOW}[6/7] Network security...${NC}"
if grep -rn "http://" lib/ --include="*.dart" 2>/dev/null | grep -v "https://" | grep -v "//.*http://"; then
  echo -e "${RED}[FAIL] HTTP (не HTTPS) в коде!${NC}"
  ISSUES=$((ISSUES+1))
else
  echo -e "${GREEN}[OK] Только HTTPS${NC}"
fi

# 7. APK размер
echo -e "${YELLOW}[7/7] APK размер...${NC}"
APK_SIZE=$(du -m "$APK" | cut -f1)
echo "  Размер: ${APK_SIZE}MB"
if [ "$APK_SIZE" -gt 150 ]; then
  echo -e "${YELLOW}[WARN] APK > 150MB (debug нормально, release должен быть < 50MB)${NC}"
else
  echo -e "${GREEN}[OK] Размер в норме${NC}"
fi

echo ""
if [ $ISSUES -gt 0 ]; then
  echo -e "${RED}=== НАЙДЕНО ПРОБЛЕМ: $ISSUES ===${NC}"
  exit 1
else
  echo -e "${GREEN}=== Аудит пройден, проблем не найдено ===${NC}"
fi
