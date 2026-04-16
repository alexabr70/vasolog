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

## Чеклист перед отправкой

### App Store
- [ ] PrivacyInfo.xcprivacy в ios/Runner/
- [ ] Medical Device Status: "Not a medical device"
- [ ] Age Rating: 9+ (нет медицинских диагнозов)
- [ ] Privacy Nutrition Labels заполнены
- [ ] Notes for App Review написаны (шаблон в store-apple-appstore.md)
- [ ] Icon: 1024×1024 PNG без альфа
- [ ] Screenshots: 1320×2868 (iPhone 6.9"), 2064×2752 (iPad 13")

### Google Play
- [ ] Organization Account (не Personal) — обязателен с янв. 2026
- [ ] Health Declaration Form заполнена в Play Console
- [ ] Data Safety Section заполнена
- [ ] Feature Graphic: 1024×500 JPEG/PNG
- [ ] Icon: 512×512 32-bit PNG
- [ ] targetSdkVersion = 35
- [ ] Staged rollout: 5% → 10% → 25% → 50% → 100%

### AppGallery
- [ ] SHA-256 fingerprint добавлен в AppGallery Connect
- [ ] APK (не AAB!)
- [ ] Минимум 3 скриншота: 1080×1920
- [ ] Age Rating questionnaire заполнен
- [ ] Fastlane plugin для автоматизации: huawei_appgallery_connect
