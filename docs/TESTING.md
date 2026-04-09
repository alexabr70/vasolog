# VasoLog - Testing Stack

Полный стек автоматизированного тестирования Flutter приложения.
Ориентирован на минимум ручного участия разработчика и максимум автоматизации.

## Оглавление

- [Обзор](#обзор)
- [Локальная отладка (ADB + scrcpy)](#локальная-отладка)
- [Unit и Widget тесты](#unit-и-widget-тесты)
- [Golden tests (visual regression)](#golden-tests)
- [Maestro E2E тесты](#maestro-e2e-тесты)
- [Fastbot (автономное exploration)](#fastbot)
- [GitHub Actions CI](#github-actions-ci)
- [Codemagic (релизы)](#codemagic-релизы)
- [Setup Huawei Pura 70 Pro](#setup-huawei-pura-70-pro)

---

## Обзор

| Слой | Инструмент | Что покрывает | Где запускается |
|---|---|---|---|
| Static analysis | `very_good_analysis` | Code smells, type safety | IDE + CI |
| Unit tests | `flutter_test` + `mocktail` | Бизнес-логика, утилиты | Локально + CI |
| Property-based | `glados` | Edge cases на рандомных входах | Локально + CI |
| Widget tests | `flutter_test` | UI компоненты | Локально + CI |
| Golden tests | `golden_toolkit` | Визуальная регрессия виджетов | Локально + CI |
| Mutation tests | `mutation_test` | Качество существующих тестов | Вручную |
| Integration | `integration_test` | Flutter полный flow | Локально + CI |
| E2E UI | `Maestro` | Реальный прогон на девайсе | Локально + CI |
| Fuzz | `adb monkey` | Рандомные краши | Локально + CI |
| Autonomous | `Fastbot` (ByteDance) | Умный exploration | Локально |
| Real device | `Firebase Test Lab Robo` | Реальные Pixel в облаке | CI (free tier) |
| Pre-launch | `Google Play Console` | Реальные девайсы Google | Автоматически после upload |
| Production monitoring | `Firebase Crashlytics` | Краши пользователей | Production |
| Security | `CodeQL` | Уязвимости | CI |

---

## Локальная отладка

### 1. Проверка ADB

```bash
./scripts/testing/adb_check.sh
```

Покажет подключённые устройства. Если пусто - включи USB Debug на телефоне.

### 2. Build, install, запуск + logcat

```bash
./scripts/testing/build_install_run.sh debug
```

Собирает debug APK, ставит, запускает приложение, тейлит logcat с фильтром по `vasolog` и `flutter`.

### 3. Скриншот с устройства

```bash
./scripts/testing/screenshot.sh bug_weather_home
# -> screenshots/bug_weather_home.png
```

### 4. Зеркало экрана (scrcpy)

```bash
scrcpy
```

Откроется окно с экраном телефона, можно управлять мышкой. Установка:
```powershell
winget install Genymobile.scrcpy
```

### 5. Flutter run с hot reload

```bash
cd d:/dev/vasolog
flutter run -d <device_id>
# r = hot reload, R = hot restart, q = quit
```

---

## Unit и Widget тесты

```bash
# Запуск всех тестов
flutter test

# С coverage
flutter test --coverage

# Конкретный файл
flutter test test/services/weather_service_test.dart

# Watch mode (авто-ре-run при изменениях)
flutter test --watch
```

Coverage отчёт: `coverage/lcov.info` → можно открыть через `lcov` или VSCode extension.

---

## Golden tests

Визуальная регрессия - тесты сравнивают виджеты с pixel-perfect эталонами.

```bash
# Запуск golden tests
flutter test test/golden/

# Обновить эталоны после UI изменений
flutter test --update-goldens test/golden/
```

Эталонные PNG лежат в `test/golden/goldens/`. Коммить их в git.

**Важно**: golden tests нужно генерировать на Linux (CI), потому что на Windows/Mac рендеринг шрифтов немного отличается. Локально можно разрабатывать, но эталон в git - с Linux.

---

## Maestro E2E тесты

Maestro - YAML сценарии которые запускаются на реальном устройстве или эмуляторе.

### Запуск всех flows локально

```bash
# Устройство должно быть подключено (adb devices)
./scripts/testing/maestro_local.sh

# Или конкретный flow
./scripts/testing/maestro_local.sh .maestro/00_smoke.yaml
```

### Интерактивная запись нового flow

```bash
maestro studio
```

Откроется браузер. Тыкаешь по экрану телефона - Maestro генерирует YAML.

### Список flows

| Flow | Что тестирует |
|---|---|
| `00_smoke.yaml` | Запуск приложения, нет краша |
| `01_weather_sync.yaml` | Синхронизация погоды между экранами |
| `02_new_attack.yaml` | Создание новой атаки, счастливый путь |
| `03_hand_diagram.yaml` | Кликабельность всех 10 пальцев |
| `04_pdf_export.yaml` | FAB не перекрывает кнопку PDF |
| `05_cold_threshold.yaml` | Нет "-0°C" в UI |
| `06_language_switch.yaml` | Переключение языка в настройках |

Добавлять новые: просто создать `.maestro/07_new_feature.yaml`.

---

## Fastbot

Fastbot (ByteDance) - умный crawler. Используется для тестирования TikTok.
Умнее обычного monkey в ~10 раз.

```bash
# 10 минут exploration
./scripts/testing/fastbot.sh 10

# 30 минут для глубокого теста перед релизом
./scripts/testing/fastbot.sh 30
```

Результат: `fastbot-output/fastbot.log` + `fastbot-output/logcat.txt`.
При нахождении краша - exit code 1.

---

## GitHub Actions CI

Автоматический pipeline: `.github/workflows/flutter_ci.yml`.

Триггеры:
- Push в `master`/`main`
- Pull request в `master`/`main`
- Ручной запуск: `gh workflow run flutter_ci.yml`

Jobs:
1. **analyze-and-test** - flutter analyze + unit tests
2. **build-android** - debug APK
3. **maestro-tests** - Android emulator + Maestro flows
4. **monkey-fuzz** - fuzz testing
5. **codeql** - security scan

Артефакты (14 дней):
- APK
- Скриншоты и видео Maestro
- Logcat
- Coverage

Просмотр результатов:
```bash
gh run list --workflow=flutter_ci.yml
gh run view <id> --log
gh run download <id>
```

---

## Codemagic (релизы)

Codemagic даёт 500 мин/мес бесплатно для Flutter **с Mac runners** (критично для iOS без своего Mac).

Конфиг: `codemagic.yaml`.

Workflows:
- `android-release` - AAB + Play Store upload (internal track)
- `ios-release` - IPA + TestFlight upload
- `pr-check` - быстрая проверка на PR

Setup:
1. Зарегистрироваться: https://codemagic.io/signup
2. Подключить GitHub repo
3. В Codemagic UI настроить:
   - `GOOGLE_PLAY_SERVICE_ACCOUNT` (JSON от Google Cloud)
   - `VasoLog_API_Key` (App Store Connect API key)
   - Android keystore (`CM_KEYSTORE`, `CM_KEYSTORE_PASSWORD`, `CM_KEY_ALIAS`, `CM_KEY_PASSWORD`)
4. Запуск: коммит с тегом `android-release` / `ios-release`, или из UI.

---

## Setup Huawei Pura 70 Pro

### 1. Включить Developer Mode

1. `Settings` → `About phone` (О телефоне)
2. Найти `Build number` (Номер сборки) - может быть внутри `Software info`
3. Тапнуть 7 раз подряд
4. Появится сообщение "You are now a developer"

### 2. Включить USB Debugging

1. `Settings` → `System & updates` → `Developer options`
2. Включить `USB debugging` (Отладка по USB)
3. Включить `Install via USB` (если есть)
4. `Default USB configuration` → `File transfer (MTP)`

### 3. Подключить к ПК

1. USB кабель → ПК
2. На телефоне: диалог `Allow USB debugging?` → поставить галочку "Always allow from this computer" → `Allow`
3. Если диалог не появился - передёрнуть кабель или: `Developer options` → `Revoke USB debugging authorizations`

### 4. Проверить

```bash
./scripts/testing/adb_check.sh
```

Должно показать модель `ALU-AL00` или подобную.

### 5. Известные проблемы Huawei

- **HDB vs ADB**: у Huawei есть свой HDB. Если `adb devices` не видит, попробовать: `Settings` → `Developer options` → выключить `Enable HDB`.
- **EMUI permissions**: EMUI агрессивно убивает фоновые процессы. Если приложение закрывается само - `Settings` → `Apps` → VasoLog → `Battery` → `Launch` → manual (снять автооптимизацию).
- **Uninstall предыдущих версий**: если новый APK не ставится из-за подписи - сначала `adb uninstall com.vasolog.vasolog`.

---

## Рекомендуемый workflow для ежедневной разработки

```
1. Изменил код
2. flutter test                          # быстро, ~5 сек
3. flutter analyze                       # ~10 сек
4. ./scripts/testing/build_install_run.sh # ~1-2 мин, ставит на телефон
5. scrcpy                                 # смотришь в окно
6. Нашёл баг → правишь → hot reload (r) → проверяешь

Перед коммитом:
7. flutter test                          # все зелёные
8. flutter analyze                       # 0 errors/warnings
9. ./scripts/testing/maestro_local.sh   # E2E проход

Перед релизом:
10. ./scripts/testing/fastbot.sh 30     # глубокий fuzz
11. git push                             # CI запустит полный pipeline
12. gh run watch                         # следим за результатами
13. Codemagic релиз в Play Console / TestFlight
```

---

## Добавление нового Flutter приложения

Этот стек переносимый. Для нового проекта:

1. `flutter create myapp`
2. Скопировать:
   - `analysis_options.yaml`
   - `.github/workflows/flutter_ci.yml`
   - `codemagic.yaml`
   - `.maestro/config.yaml`
   - `scripts/testing/*.sh`
3. Обновить `pubspec.yaml` (dev_dependencies из VasoLog)
4. Поменять `com.vasolog.vasolog` на новый package во всех файлах
5. `flutter pub get`
6. Написать первый Maestro flow
7. `git push` → CI работает
