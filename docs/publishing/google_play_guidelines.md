# Google Play Guidelines - VasoLog
> Актуально на апрель 2026. Источники: support.google.com/googleplay/android-developer

---

## Лимиты текстовых метаданных

| Поле | Лимит | Примечания |
|------|-------|-----------|
| App Name | **50 символов** | В листинге (Launcher name - 30 символов) |
| Short Description | **80 символов** | Первое, что видит пользователь |
| Full Description | **4 000 символов** | HTML-разметка не отображается |
| Keywords | **нет отдельного поля** | Встраивать в Title + Short + Full Description |

**ВАЖНО:** Google Play не имеет отдельного поля keywords (в отличие от App Store).
Ключевые слова индексируются из названия и описания. `keywords.txt` для Google Play не используется.

**Источник:** https://support.google.com/googleplay/android-developer/answer/9898842

---

## Визуальные ресурсы

### Feature Graphic (обязателен)
- Размер: **1024 × 500 px**
- Формат: JPEG или PNG 24-bit (без альфа-канала)
- Путь: `release/v1.1.0/assets/feature_graphic/`

### Screenshots
- Минимум: **2**, максимум: **8** на тип устройства
- Размер: 320-3840 px, соотношение сторон не более 2:1
- Форматы: JPEG или PNG 24-bit
- Рекомендуется 4+ скриншота
- Первые 2-3 скриншота видны в поиске

### App Icon
- Размер: **512 × 512 px**
- Формат: **32-bit PNG с альфа-каналом**
- Макс. размер файла: 1024 KB

### Promo Video (опционально)
- Длительность: **30-120 секунд**
- Только YouTube URL (public или unlisted)
- Снятый в ландшафтной ориентации
- Монетизацию на видео ОТКЛЮЧИТЬ

---

## Категория
- VasoLog: **Health & Fitness**
- Путь: Play Console > Store listing > App category

---

## Content Rating
Заполнить questionnaire в Play Console (Monitor & Improve > Policy > App content):
- Violence: Minimal (нет)
- Blood/gore: нет
- Drugs/Alcohol/Tobacco: нет
- Language: нет
- Sexual content: нет
- Gambling: нет

Это сгенерирует рейтинги: PEGI 3 (EU), ESRB Everyone (NA) и т.д.

---

## Требования для Health приложений (2026)

### Health Declaration Form
- Заполнить в Play Console: Monitor & Improve > Policy > App content
- Указать что VasoLog является трекером симптомов (не медицинским устройством)

### Обязательные дисклеймеры (добавить в Full Description)
```
Приложение не является медицинским устройством и не диагностирует, не лечит
и не предотвращает никакие заболевания. Перед принятием медицинских решений
проконсультируйтесь с врачом.
```

### Privacy Policy
- Публично доступный URL (не PDF, не геозащищённый)
- Указать в Play Console + внутри приложения
- Раскрыть: какие данные собираются, цель, хранение (Hive - локально)
- VasoLog не собирает данные в облако - это конкурентное преимущество!

### Organization Account (с 28 января 2026)
Health apps должны быть опубликованы от Organization Account (не Personal).
Источник: https://myappmonitor.com/blog/google-play-health-apps-update-2026-requirements

---

## Локализация

- Google Play поддерживает 70+ локалей
- Каждый язык: отдельный Title + Short Desc + Full Desc
- Путь: `release/v1.1.0/metadata/_platform_specific/google_play/{locale}/`

### Особенности для Google Play (vs App Store):
1. **Нет keywords.txt** - не загружать этот файл
2. **Title до 50 символов** (App Store = 30) - можно расширить если нужно
3. **Short Desc до 80 символов** - совпадает с App Store
4. **Full Desc до 4000** - совпадает с App Store

---

## Публикация APK/AAB

- Формат: **AAB (Android App Bundle)** рекомендуется (меньший размер)
- Альтернатива: APK
- Подписывание: через Google Play App Signing (рекомендуется)
- Минимум SDK: android:minSdkVersion="21" (Android 5.0)

Путь артефактов: `release/v1.1.0/artifacts/` (в .gitignore, не хранится в git)

---

## Источники

- https://support.google.com/googleplay/android-developer/answer/9866151 (Preview assets)
- https://support.google.com/googleplay/android-developer/answer/13393723 (Best practices)
- https://support.google.com/googleplay/android-developer/answer/16679511 (Health Content)
- https://developer.android.com/distribute/google-play/resources/icon-design-specifications
