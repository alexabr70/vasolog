# VasoLog - Data Safety form

**Источник анализа:** AndroidManifest.xml + код Flutter + Firebase config
**Дата:** 2026-05-14
**Категория:** Health & Fitness (не Medical)

## Что собирает VasoLog

| Источник | Что | Куда |
|---|---|---|
| `ACCESS_COARSE_LOCATION` | Approximate location (для weather) | OpenWeatherMap API (3rd party) |
| `image_picker` | Фото приступа | Локально на устройстве |
| User input | Health info (приступы, severity, color phase, triggers) | Локально на устройстве (SharedPreferences) |
| Firebase Analytics | App activity, screen views | Google Firebase |
| Firebase Crashlytics | Crash logs, diagnostics | Google Firebase |
| Firebase Analytics | Anonymous device IDs | Google Firebase |

## Ответы Data Safety (14 категорий)

### 1. Location
- **Approximate location**
  - Collected: **YES**
  - Shared: **YES** (с OpenWeatherMap для получения погоды)
  - Optional or Required: **Optional** (приложение работает без)
  - Purpose: **App functionality** (корреляция погоды и приступов)
  - Processed ephemerally: **No** (хранится в записи приступа)
  - User can request deletion: **Yes** (uninstall app)
- Precise location: **NO**

### 2. Personal info
Все поля: **NO** (имя, email, address, user IDs, phone, race/ethnicity, religion, sexual orientation, политика, другая личная инфа - не собирается)

### 3. Financial info
Все поля: **NO**

### 4. Health and fitness
- **Health info** (medical history, symptoms)
  - Collected: **YES** (записи приступов: фазы, severity RCS 0-10, длительность, триггеры)
  - Shared: **NO** (только локально на устройстве)
  - Optional/Required: **Required** (core functionality)
  - Purpose: **App functionality**
  - Processed ephemerally: **No**
  - User can request deletion: **Yes**
- **Fitness info**: **NO**

### 5. Messages
Все поля: **NO**

### 6. Photos and videos
- **Photos**
  - Collected: **YES** (через image_picker, прикрепление к приступу)
  - Shared: **NO** (только локально)
  - Optional/Required: **Optional**
  - Purpose: **App functionality**
  - Processed ephemerally: **No**
  - User can request deletion: **Yes**
- Videos: **NO**

### 7. Audio files
Все: **NO**

### 8. Files and docs
Все: **NO**

### 9. Calendar
**NO**

### 10. Contacts
**NO**

### 11. App activity
- **App interactions** (screen views, app_open events)
  - Collected: **YES** (через Firebase Analytics)
  - Shared: **YES** (Google Firebase)
  - Optional/Required: **Optional**
  - Purpose: **Analytics**
  - Processed ephemerally: **No**
- In-app search history: **NO**
- Installed apps: **NO**
- Other user-generated content: **NO**
- Other actions: **NO**

### 12. Web browsing
**NO**

### 13. App info and performance
- **Crash logs**
  - Collected: **YES** (Firebase Crashlytics)
  - Shared: **YES** (Google Firebase)
  - Optional/Required: **Optional**
  - Purpose: **Analytics**
- **Diagnostics** (performance metrics)
  - Collected: **YES** (Firebase Crashlytics performance)
  - Shared: **YES** (Google Firebase)
  - Purpose: **Analytics**
- Other app performance data: **NO**

### 14. Device or other IDs
- **Device or other IDs** (Firebase anonymous Instance ID)
  - Collected: **YES**
  - Shared: **YES** (Google Firebase)
  - Optional/Required: **Optional**
  - Purpose: **Analytics**

## Дополнительные вопросы (Security Practices)

- **Все данные зашифрованы при передаче?** **YES** (TLS - все Firebase + OpenWeatherMap)
- **Пользователь может запросить удаление?** **YES** (uninstall app удаляет все данные, ничего в облаке)
- **Соответствие Play Families Policy?** **NO** (не для детей)
- **Прошло независимый security review?** **NO**
- **Сторонние партнёры подписали contracts на соблюдение privacy?** **YES** (Google Firebase, OpenWeatherMap имеют DPAs)
- **Какие категории данных можно удалить?** Все (uninstall = delete all)

## Privacy Policy
URL: `https://alexabr70.github.io/vasolog/privacy_policy.html`
