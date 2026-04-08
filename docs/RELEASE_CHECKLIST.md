# VasoLog - Release Checklist

## Сборка с обфускацией

```bash
# Android (AAB для Google Play)
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=./build/symbols \
  --dart-define=WEATHER_API_KEY=963fe87900f276da9f0957b422accfea

# Android (APK для тестирования)
flutter build apk --release \
  --obfuscate \
  --split-debug-info=./build/symbols \
  --dart-define=WEATHER_API_KEY=963fe87900f276da9f0957b422accfea

# iOS
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=./build/symbols \
  --dart-define=WEATHER_API_KEY=963fe87900f276da9f0957b422accfea
```

Символы для crash reports сохраняются в `./build/symbols/`.
Загрузить их в Firebase Crashlytics или Google Play Console.

## Medical Device Declaration

### App Store Connect
1. App Store Connect -> App -> General -> App Information
2. Секция "Medical Device" -> ответить на вопросы:
   - "Is this app a medical device?" -> **No**
   - "Does this app provide medical diagnoses?" -> **No**
3. Объяснение: VasoLog is a wellness/symptom tracker, not a medical device.
   It does not diagnose, treat, or prevent any disease.

### Google Play Console
1. Google Play Console -> App Content -> Health apps
2. Заполнить health apps questionnaire:
   - App is a health/fitness tracker: **Yes**
   - App provides medical diagnoses: **No**
   - App is a regulated medical device: **No**
3. Добавить medical disclaimer (уже есть в about_screen)

## Privacy Policy URL
Опубликовать `docs/privacy_policy.html` на GitHub Pages:
```bash
# Создать репозиторий vasolog-app.github.io
# Или включить GitHub Pages в настройках текущего репозитория (docs/ folder)
```
URL для App Store Connect и Google Play Console:
`https://vasolog-app.github.io/privacy_policy.html`

## Перед публикацией
- [ ] flutter analyze = 0 issues
- [ ] flutter test = все зелёные
- [ ] Проверить на реальном устройстве (Android + iOS)
- [ ] Скриншоты для store listing (5-8 штук, 9:16)
- [ ] Feature Graphic 1024x500 (Google Play)
- [ ] Privacy Policy URL работает
- [ ] Medical Device Declaration заполнена
