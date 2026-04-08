# VasoLog: Полный аудит, архитектура и стратегия выхода в сторы

## Context

VasoLog - Flutter-приложение для трекинга феномена Рейно. Текущее состояние: MVP готов (v1.1.0, 7 экранов, ~2000 строк, APK 53MB), но для публикации в App Store / Google Play и достижения топ-уровня нужен серьёзный polish.

Аудит проведён 9 экспертными агентами (Google Play, App Store, UX, ASO, Growth, Flutter, Medical UX, Credibility, Technical Polish) на основе 150+ внешних источников (Apple HIG, Google Play Policy, Reddit, GitHub, PMC, Adapty, MobileAction, Raynaud's Association).

Конкуренты: **практически нулевая** конкуренция в нише Raynaud's apps. Рынок $12.9B (2024) → $23.1B (2032). Голубой океан.

---

## Текущая архитектура

```
lib/ (~2000 строк, 15 файлов)
├── main.dart (121) - точка входа, тема Material3, light+dark
├── screens/
│   ├── main_shell.dart (203) - BottomAppBar + FAB + AnimatedSwitcher
│   ├── home_screen.dart (378) - дашборд, StatCard, AttackTile, триггеры
│   ├── new_attack_screen.dart (490) - форма записи + shimmer + haptic
│   ├── history_screen.dart (261) - график fl_chart + ExpansionTile
│   ├── report_screen.dart (218) - PDF генерация + Printing
│   ├── about_screen.dart (158) - дисклеймер + privacy policy
│   └── onboarding_screen.dart (200) - 3 страницы PageView
├── models/
│   └── attack_event.dart (115) - HiveObject, 15+ полей
├── providers/
│   └── attack_provider.dart (54) - ChangeNotifier, CRUD + агрегаты
├── services/
│   ├── storage_service.dart (72) - Hive CRUD
│   ├── weather_service.dart (108) - OpenWeatherMap + кэш 30мин
│   ├── location_service.dart (32) - Geolocator
│   └── pdf_report_service.dart (154) - pw.Document генерация
└── utils/
    └── constants.dart (75) - цвета, триггеры, пальцы
```

**Stack**: Flutter 3.11, Provider, Hive, fl_chart, OpenWeatherMap API
**State**: Provider (ChangeNotifier)
**Storage**: Hive (NoSQL) + SharedPreferences (кэш, флаги)
**Tests**: 0

---

## ФАЗА 1: БЛОКЕРЫ ПУБЛИКАЦИИ (1-2 дня)

Без этих пунктов reject гарантирован в обоих сторах.

### 1.1 API ключ из кода → dart-define
**Файл**: `lib/services/weather_service.dart:50`
```
- Убрать: static const String _apiKey = '963fe879...';
- Заменить: String.fromEnvironment('WEATHER_API_KEY')
- Сборка: flutter build apk --dart-define=WEATHER_API_KEY=xxx
```

### 1.2 Иконка: убрать встроенные скругления
**Файл**: `assets/icon/icon.png`
```
- Текущая иконка имеет встроенный rounded square
- iOS сам скругляет → получится двойное скругление
- Действие: Python скрипт - убрать прозрачные углы, заполнить navy фоном до краёв
- Также: pubspec.yaml → remove_alpha_ios: true
```

### 1.3 Privacy Manifest (iOS 17+)
**Файл**: `ios/Runner/PrivacyInfo.xcprivacy` (создать)
```
- Обязателен для App Store с iOS 17
- Указать: NSPrivacyTracking = false
- NSPrivacyCollectedDataTypes: location (для погоды), photos
- NSPrivacyAccessedAPITypes: UserDefaults, SystemBootTime
```

### 1.4 Privacy Policy URL
**Файл**: `lib/screens/about_screen.dart`
```
- Создать privacy_policy.html → GitHub Pages
- Добавить URL в about_screen (launchUrl)
- URL нужен и в App Store Connect, и в Google Play Console
```

### 1.5 Target SDK 35
**Файл**: `android/app/build.gradle.kts` (или build.gradle)
```
- Явно: compileSdk = 35, targetSdk = 35
- Без этого Google Play не примет новые приложения в 2026
```

### 1.6 JSON парсинг Weather - try-catch
**Файл**: `lib/services/weather_service.dart:70-76`
```
- Обернуть json.decode + field access в try-catch
- При ошибке → return _loadFromCache()
- Без этого: API вернёт неожиданный формат → краш
```

### 1.7 Race condition StorageService
**Файл**: `lib/main.dart:19-26`
```
- Гарантировать что storage.init() завершён до создания Provider
- Текущий код: storage ??= StorageService() после ошибки → без init()
- Это LateInitializationError при первом обращении к Hive
```

### 1.8 Error handling при сохранении
**Файл**: `lib/screens/new_attack_screen.dart:118`
```
- addAttack() без try-catch
- Если диск переполнен → данные потеряны без уведомления
- Обернуть + показать SnackBar с ошибкой
```

---

## ФАЗА 2: РЕВЬЮ-READY (2-3 дня)

### 2.1 Edge-to-edge display (Android 15)
**Файл**: `android/app/src/main/AndroidManifest.xml`
```
- android:enableOnBackInvokedCallback="true"
- PredictiveBackPageTransitionsBuilder в ThemeData
- Обязательно с Android 16, рекомендуется с 15
```

### 2.2 Obfuscation
```
flutter build appbundle --release --obfuscate --split-debug-info=./build/symbols
- Уменьшает размер + защищает код
- 53MB → ~35-40MB
```

### 2.3 Adaptive icon safe zone
**Файл**: `assets/icon/icon_foreground.png`
```
- Рука слишком близко к краям
- При обрезке до 66% safe zone → пальцы обрезаются
- Нужен отдельный foreground с рукой уменьшенной на 15-20%
```

### 2.4 Location denied → сообщение
**Файл**: `lib/screens/new_attack_screen.dart`
```
- Если position == null → SnackBar "Включите геолокацию для погоды"
- Сейчас молча не загружает - пользователь не понимает
```

### 2.5 Контрастность AppBar
**Файл**: `lib/utils/constants.dart`
```
- Белый на #7E57C2 = контраст ~3:1 (WCAG AA требует 4.5:1)
- Сделать gradientEnd темнее или текст ярче
```

### 2.6 Medical Device Declaration
```
- App Store Connect: заполнить форму Medical Device Declaration (EEA/US)
- Для wellness tracker без диагностики → exempt, но форму заполнить обязательно
```

---

## ФАЗА 3: RETENTION (1 неделя)

### 3.1 Push notifications
```
Пакет: flutter_local_notifications + timezone
- Еженедельное напоминание: "Как ваши руки сегодня?"
- После 3 дней без записи: "Давно не было записей. Всё хорошо?"
- Время: 12:30 (lunch break, лучший engagement)
- Эффект: 6-10x retention (BuildFire 2026)
```

### 3.2 Home screen widget
```
Пакет: home_widget
- Показывать: дни с последнего приступа / средняя тяжесть за неделю
- Circular format, макс 20 символов
- Эффект: +45% daily opens
```

### 3.3 In-app review
```
Пакет: in_app_review
- Триггер: после 5-го записанного приступа
- НИКОГДА при onboarding или time-sensitive tasks
- Макс 1 раз в месяц
```

### 3.4 Logging UX оптимизация
```
Текущий: ~40 сек на запись (scroll + выбор + scroll)
Цель: <15 сек
- Severity slider сразу виден (без scroll)
- Quick preset: "Как прошлый раз" кнопка
- Умные дефолты: последний colorPhase, последние триггеры
- Автозаполнение пальцев из прошлого раза
```

### 3.5 Gamification (streak)
```
- "Дней без приступа" счётчик на HomeScreen
- Milestone: 7 дней → celebration animation + haptic
- Grace period: 1 день пропуска не ломает streak (chronic disease!)
- Эффект: +15-20% health outcomes, +50% retention
```

### 3.6 Deep linking
```
Пакет: app_links / uni_links
- Push notification → конкретный экран (не просто открыть app)
- Email → ссылка на отчёт
- Эффект: +500% re-engagement
```

---

## ФАЗА 4: ASO И ПУБЛИКАЦИЯ

### 4.1 Store listing
```
Title (30): "VasoLog: Raynaud's Tracker"
Subtitle: "Track attacks, triggers & weather"
Keywords (100): raynaud,phenomenon,cold fingers,vasospasm,tracker,symptom,flare,trigger

Описание: проблема → решение → фичи → disclaimer → privacy
Скриншоты: 5-8 штук, 9:16, текст с keywords (Apple OCR индексирует)
Feature Graphic: 1024x500 (Google Play)
```

### 4.2 Custom Product Pages (Apple)
```
- Страница для пациентов: "Track your Raynaud's attacks"
- Страница для врачей: "PDF reports for rheumatologists"
- Появляются в органическом поиске с июля 2025
```

### 4.3 In-App Events (Apple) + LiveOps (Google)
```
- Зимний event: "Winter Raynaud's Challenge - log daily for 30 days"
- Готовить за 2 месяца до ноября (пик сезона)
- Бесплатная промо-карточка в сторе
```

### 4.4 Процесс публикации
```
1. Internal testing (Google Play) - 20+ тестеров, 14 дней
2. TestFlight (Apple) - 50 пациентов из patient groups
3. Closed testing → Production staged rollout 5%
4. Мониторинг: crash-free >99%, ANR <0.47%
```

---

## ФАЗА 5: "ВАУ" ФИЧИ (post-launch roadmap)

### 5.1 Apple Health / HealthKit
```
- FHIR-native стандарт 2026
- Экспорт приступов в Apple Health
- Без этого не попасть в Featured
- 3 дня работы
```

### 5.2 AI insights (Claude API)
```
- "Ваши приступы коррелируют с температурой <5°C"
- "За последний месяц тяжесть снизилась на 20%"
- Персонализированные рекомендации
- Killer feature, нет у конкурентов
- 3-5 дней
```

### 5.3 Apple Watch
```
- Quick log приступа с запястья
- Complication: дни без приступа
- +45% engagement
- 3-5 дней
```

### 5.4 Biometric lock
```
Пакет: local_auth
- FaceID / отпечаток для доступа к медданным
- HIPAA/GDPR compliance
- 1 день
```

### 5.5 Cloud backup
```
- iCloud (iOS) / Google Drive (Android)
- При смене телефона данные не теряются
- 2-3 дня
```

### 5.6 Doctor referral loop
```
- QR-код в PDF-отчёте → ссылка на скачивание app
- Врач показывает пациенту → organic install
- 1 день
```

### 5.7 WCAG 2.2 AA accessibility
```
- Semantics labels на все интерактивные элементы
- Dynamic Type support
- Tap targets 48x48 minimum
- Дедлайн HHS: июнь 2026. Только 33% health apps проходят
- 2 дня
```

---

## ФАЗА 6: GROWTH ENGINE

### 6.1 Партнёрство с Raynaud's Association
```
- SRUK (UK): уже делали Raynaud's App → контакт research@sruk.co.uk
- Raynaud's Association (US): 275K посещений в зимнюю кампанию 2025
- Предложить: бесплатный доступ для членов + анонимные данные для research
```

### 6.2 Content marketing
```
- Блог: "Raynaud's triggers in winter", "managing flares"
- SEO трафик → landing page → скачивание
- Требуется: credentialed medical writer
```

### 6.3 Pre-launch waitlist
```
- Landing page + email signup
- Product Hunt launch
- 3-5x лучше ranking с waitlist
```

### 6.4 Featured nomination
```
- App Store Connect: подать за 2-3 месяца до launch
- Критерии: дизайн + инновация + accessibility + локализация
```

---

## ЭМОЦИОНАЛЬНЫЙ ДИЗАЙН (что отличает 4.8 от 4.2)

### Cognitive accessibility
```
- Brain fog частый при аутоиммунных → макс 3 элемента на экране
- Словарь пациента, не врача
- Один навигационный паттерн по всему приложению
```

### Magic moment за 30 секунд
```
- Не onboarding tour, а мгновенное действие
- "Запиши первый приступ → увидь карту здоровья"
- 60% уходят если tour > 5 экранов
```

### Empathy в UI
```
- "Многие чувствуют растерянность. Мы здесь" > "Начнём!"
- Empty states: "3 записи до первого insight" > "Нет данных"
- Celebration при milestone (confetti, haptic)
```

### Data visualization
```
- "Лучше чем неделю назад" понимают 78%
- "155 единиц" понимают только 45%
- Цветовое кодирование + относительные метрики
```

---

## ТЕХНИЧЕСКИЙ POLISH

### Physics-based анимации
```
- SpringSimulation вместо linear curves
- Damping + stiffness → ощущение "живого" UI
- 200-350ms transitions (не дольше → lag)
```

### Platform-adaptive
```
- Switch.adaptive(), Slider.adaptive()
- iOS: Cupertino look, Android: Material
```

### Offline-first
```
- CRDT для conflict-free merge
- Outbound queue → retry при reconnect
- Exponential backoff
```

### Shader warmup
```
flutter run --profile --cache-sksl
flutter build --bundle-sksl-path flutter_01.sksl.json
- Jank 90ms → 40ms на первой анимации
```

---

## МОНЕТИЗАЦИЯ

```
Freemium:
- Бесплатно: трекинг, история, базовый отчёт
- Premium ($2.99/мес): AI insights, widget, export, cloud backup

Hard paywall = LTV +21% vs soft paywall (Adapty 2026)
Локализованные цены: 4.4x разница в LTV между странами
Ads: КАТЕГОРИЧЕСКИ НЕТ для health app
```

---

## АРХИТЕКТУРНЫЕ ПРОБЛЕМЫ (исправить при рефакторинге)

1. **Нет Repository Pattern** - StorageService напрямую в Provider
2. **Business logic в Screens** - _loadWeather(), _updateSuggestedTriggers() в UI
3. **Все данные в памяти** - getAllAttacks() загружает всё → тормоз на 10k+
4. **Нет Database Migrations** - Hive без версионирования схемы
5. **0 тестов** - unit, widget, integration = 0
6. **Tight coupling** - StorageService передаётся как параметр
7. **Нет Input Validation** - можно сохранить пустой приступ
8. **Только portrait** - нет адаптивного дизайна для tablet/landscape

---

## VERIFICATION

После каждой фазы:
```bash
flutter analyze                    # 0 ошибок
flutter test                       # все зелёные (когда появятся тесты)
flutter build apk --release        # собирается
flutter build appbundle --release  # для Google Play
# Установить на устройство и проверить:
# - Shimmer при загрузке погоды
# - Haptic на слайдерах
# - Иконка без двойного скругления
# - Все экраны работают
# - Offline режим не крашит
```

---

## ПРИОРИТЕТ РЕАЛИЗАЦИИ

| Приоритет | Фаза | Время | Статус |
|-----------|-------|-------|--------|
| P0 | Фаза 1: Блокеры | 1-2 дня | TODO |
| P1 | Фаза 2: Ревью-ready | 2-3 дня | TODO |
| P2 | Фаза 3: Retention | 1 неделя | TODO |
| P3 | Фаза 4: ASO + публикация | 3-5 дней | TODO |
| P4 | Фаза 5: "Вау" фичи | ongoing | Roadmap |
| P5 | Фаза 6: Growth | ongoing | Roadmap |
