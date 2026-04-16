# Publishing — VasoLog v1.1.0

Полные гайдлайны для всех сторов хранятся в ОБЩЕЙ knowledge-base (используй для любого проекта):

| Стор | Документ |
|------|---------|
| App Store | `knowledge-base/kb-docs/store-apple-appstore.md` |
| Google Play | `knowledge-base/kb-docs/store-google-play.md` |
| AppGallery | `knowledge-base/kb-docs/store-appgallery.md` |
| Сравнение лимитов | `knowledge-base/kb-docs/store-appgallery.md` (раздел 13) |

---

## VasoLog — Лимиты метаданных

| Поле | App Store | Google Play | AppGallery |
|------|-----------|------------|------------|
| Title | **30** | **50** | **64** |
| Short Desc | 30 (subtitle) | 80 | 80 |
| Keywords | да (100) | **нет** | **нет** |
| Full Desc | 4 000 | 4 000 | 8 000 |

## Структура метаданных VasoLog

```
release/v1.1.0/metadata/
├── {locale}/                   ← App Store (по умолчанию)
│   ├── title.txt               ← ≤30 символов
│   ├── subtitle.txt            ← ≤30 символов
│   ├── keywords.txt            ← ≤100 (ТОЛЬКО App Store)
│   ├── description_short.txt   ← ≤80 символов
│   ├── description_full.txt    ← ≤4000 символов
│   └── changelog.txt
│
└── _platform_specific/
    ├── google_play/{locale}/
    │   └── description_full.txt ← оригинал + дисклеймер (нет keywords!)
    └── appgallery/{locale}/
        └── description_full.txt ← оригинал + дисклеймер (нет keywords!)
```

Локали: en, ru, de, fr, ja, it, es, pt-br, pt, nl, sv, tr, pl (13 языков)

## Store Assets (готово)

```
release/v1.1.0/store_assets/
├── icons/
│   ├── appstore_1024x1024.png      ← RGB без альфа (App Store требует)
│   ├── googleplay_512x512.png
│   └── appgallery_216x216.png
├── feature_graphic/
│   └── feature_1024x500.jpg        ← Google Play + AppGallery
└── screenshots/
    ├── appstore/                   ← 1320×2868 letterbox (iPhone 6.9")
    │   ├── 01_home.png
    │   ├── 02_new_attack.png
    │   ├── 03_finger_diagram.png
    │   ├── 04_reports.png
    │   └── 05_pdf_export.png
    ├── google_play/                ← 1260×2844 as-is
    └── appgallery/                 ← 1260×2844 as-is
```

Пересоздать: `py scripts/prepare_store_assets.py`

---

## Чеклист перед отправкой

### App Store
- [x] PrivacyInfo.xcprivacy в ios/Runner/
- [x] Метаданные 13 языков в release/v1.1.0/metadata/
- [x] Icon: 1024×1024 PNG без альфа → store_assets/icons/appstore_1024x1024.png
- [x] Screenshots 1320×2868 → store_assets/screenshots/appstore/
- [ ] IPA сборка через Codemagic
- [ ] Medical Device Status: "Not a medical device"
- [ ] Age Rating: 9+ (нет медицинских диагнозов)
- [ ] Privacy Nutrition Labels заполнены в App Store Connect
- [ ] Notes for App Review написаны (шаблон в store-apple-appstore.md)
- [ ] Apple Developer: Bundle ID `com.vasolog.app` зарегистрирован
- [ ] Codemagic: App Store Connect API key настроен (VasoLog_API_Key)

### Google Play
- [x] Метаданные 13 языков (platform_specific/google_play/)
- [x] Icon 512×512 → store_assets/icons/googleplay_512x512.png
- [x] Feature Graphic 1024×500 → store_assets/feature_graphic/feature_1024x500.jpg
- [x] Screenshots → store_assets/screenshots/google_play/
- [ ] Organization Account (не Personal) — обязателен с янв. 2026
- [ ] Health Declaration Form заполнена в Play Console
- [ ] Data Safety Section заполнена
- [ ] AAB сборка через Codemagic
- [ ] targetSdkVersion = 35 (проверить android/app/build.gradle)
- [ ] Codemagic: GCLOUD_SERVICE_ACCOUNT_CREDENTIALS настроен
- [ ] Staged rollout: 5% → 10% → 25% → 50% → 100%

### AppGallery
- [x] Метаданные 13 языков (platform_specific/appgallery/)
- [x] Icon 216×216 → store_assets/icons/appgallery_216x216.png
- [x] Feature Graphic → store_assets/feature_graphic/feature_1024x500.jpg
- [x] Screenshots (5 шт.) → store_assets/screenshots/appgallery/
- [ ] Регистрация приложения в AppGallery Connect
- [ ] SHA-256 fingerprint добавлен в AppGallery Connect
- [ ] APK сборка (не AAB!)
- [ ] Age Rating questionnaire заполнен
