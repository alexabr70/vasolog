# Сравнение лимитов метаданных - App Store vs Google Play vs AppGallery
> Апрель 2026

## Текстовые поля

| Поле | App Store | Google Play | AppGallery | Примечание |
|------|-----------|------------|------------|-----------|
| **Title** | **30** | **50** | **64** | Разные! |
| Subtitle / Short Desc | 30 | 80 | 80 | |
| Keywords | **100** (отд. поле) | **нет поля** | **нет поля** | Только App Store! |
| Full Description | 4 000 | 4 000 | **8 000** | AppGallery больше |
| Promo Text | 170 | - | - | Только App Store |

## Визуальные ресурсы

| Ресурс | App Store | Google Play | AppGallery |
|--------|-----------|------------|------------|
| **Icon** | 1024×1024 PNG | 512×512 PNG (32-bit) | 216×216 или 512×512 PNG |
| **Feature Graphic** | нет | **1024×500** | ~1024×500 (уточнить) |
| Screenshots мин | **1** | **2** | **3** |
| Screenshots макс | 10 | 8 | 8 |
| Screenshot (Phone) | 1320×2868 | 320-3840 px | 1080×1920 |

## Архитектура файлов

```
release/v1.1.0/metadata/
├── en/                    ← общие файлы (App Store по умолчанию)
│   ├── title.txt          ← ≤30 символов
│   ├── subtitle.txt       ← ≤30 символов
│   ├── keywords.txt       ← ≤100 символов (ТОЛЬКО для App Store!)
│   ├── description_short.txt  ← ≤80 символов
│   ├── description_full.txt   ← ≤4000 символов
│   └── changelog.txt
│
└── _platform_specific/
    ├── google_play/
    │   └── en/
    │       ├── title.txt      ← ≤50 символов (можно расширить)
    │       └── description_full.txt  ← ≤4000 (+ дисклеймер)
    │       [НЕТ keywords.txt!]
    └── appgallery/
        └── en/
            ├── title.txt      ← ≤64 символов
            ├── description_full.txt   ← ≤8000 (можно расширить)
            [НЕТ keywords.txt!]
```

## Критические отличия - чек-лист перед загрузкой

### App Store
- [ ] title ≤30 символов
- [ ] keywords.txt есть и ≤100 символов
- [ ] Minimum 1 screenshot per device type
- [ ] Icon 1024×1024 PNG без альфа
- [ ] Medical Device Status disclosure (для EEA/UK/US - к 2027)

### Google Play
- [ ] title ≤50 символов
- [ ] keywords.txt НЕ загружать (нет такого поля)
- [ ] description содержит дисклеймер о не-медицинском устройстве
- [ ] Feature graphic 1024×500 обязателен
- [ ] Icon 512×512 32-bit PNG с альфа
- [ ] Health Declaration Form заполнена в Play Console
- [ ] Organization Account (с января 2026)

### AppGallery
- [ ] title ≤64 символов
- [ ] keywords.txt НЕ загружать
- [ ] Minimum 3 скриншота
- [ ] description_full ≥100 символов
- [ ] Icon 216×216 или 512×512 PNG
- [ ] Дисклеймер о не-медицинском устройстве
