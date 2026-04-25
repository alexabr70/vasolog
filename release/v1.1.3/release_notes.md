# VasoLog v1.1.3 (build 10)

**Release date:** 2026-04-25
**Channel:** AppGallery (Huawei)
**APK:** `vasolog-v1.1.3-10-appgallery.apk` (~68 MB)

## What's new

- Firebase Crashlytics: production crash reporting (Flutter + Android native)
- Firebase Analytics: automatic app_open / first_open / screen_view tracking
- `setCrashlyticsCollectionEnabled(!kDebugMode)` - debug-сборки не засоряют отчёты
- `setAnalyticsCollectionEnabled(!kDebugMode)` - аналогично для Analytics
- `FirebaseAnalyticsObserver` подключён к `MaterialApp.navigatorObservers` - автотрекинг экранов

## Tech changes

- `pubspec.yaml`: bump 1.1.2+9 → 1.1.3+10
- `android/settings.gradle.kts`:
  - `com.google.gms.google-services` 4.3.15 → 4.4.2
  - `com.google.firebase.crashlytics` 3.0.2 (новый)
- `android/app/build.gradle.kts`: подключён `id("com.google.firebase.crashlytics")`
- `lib/main.dart`: импорт `firebase_analytics`, инициализация Analytics + Observer

## Firebase Console - что включить

Project: `flutter-mobile-apps-32266`

1. **Crashlytics**: Build → Crashlytics → Enable. Первый отчёт появится после первого краша в release.
2. **Analytics**: ⚙ Project settings → Integrations → Google Analytics → Link → принять ToS.

После включения `IS_ANALYTICS_ENABLED` в `google-services.json` поменяется на `true` (на следующем `flutterfire configure`).

## Privacy Policy

Опубликована на [alexabr70.github.io/vasolog/privacy_policy.html](https://alexabr70.github.io/vasolog/privacy_policy.html).
Указан разработчик: **Aliaksandr Abrashkin** (Overview + Contact Us). Last updated: April 20, 2026.

## QA

- `flutter analyze` - 41 issues, все info-level (pre-existing, не связаны с релизом)
- `flutter build apk --release` - exit 0, APK 68.4 MB
- `flutter test` - см. CI лог

## AppGallery upload checklist

- [ ] Загрузить `vasolog-v1.1.3-10-appgallery.apk`
- [ ] Privacy Policy URL: https://alexabr70.github.io/vasolog/privacy_policy.html
- [ ] Versions: name=1.1.3, code=10
- [ ] Release notes (см. ниже копировать в форму)

### Release notes для AppGallery (EN)

```
v1.1.3 - April 25, 2026

What's new:
- Improved crash reporting for faster bug fixes
- Anonymous usage analytics to better understand which features users need
- Stability improvements

Privacy: All health data still stays on your device. Only crash logs and basic
app-usage events (screen views, sessions) are sent to Firebase to help us
improve the app. No personal data, no health records leave your device.
```
