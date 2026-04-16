# Huawei AppGallery Guidelines - VasoLog
> Актуально на апрель 2026. Источники: developer.huawei.com, Phiture, Appradar

---

## Лимиты текстовых метаданных

| Поле | Лимит | Примечания |
|------|-------|-----------|
| App Name | **3-64 символа** | Уникальное, без `*`, `&`, названий конкурентов |
| Brief Introduction | **80 символов** | Краткое описание |
| Detailed Introduction | **100-8 000 символов** | Минимум 100 обязателен |
| Keywords | **нет отдельного поля** | Встраивать в Name + Introduction |

**ВАЖНО:** AppGallery не имеет отдельного поля keywords.
`keywords.txt` для AppGallery не используется.

**Источник:** https://phiture.com/asostack/huawei-appgallery-search-visibility-6a1a98e9b004/

---

## Визуальные ресурсы

### App Icon
| Параметр | Требование |
|----------|-----------|
| Основной размер | **216 × 216 px** |
| Исходник | 512 × 512 px |
| Формат | PNG (до 2 MB) |
| Прозрачный фон | поддерживается |

### Screenshots (обязательны)
| Параметр | Требование |
|----------|-----------|
| Минимум | **3 скриншота** |
| Максимум | **8 скриншотов** |
| Рекомендуемый размер | 1080 × 1920 px (Portrait) |
| Минимальный размер | 450 × 800 px |
| Landscape | 800 × 450 px |
| Форматы | PNG, JPG, JPEG (до 2 MB); WEBP (до 100 KB) |
| Соотношение сторон | 9:16 или 16:9 |

**Источник:** https://appradar.com/blog/huawei-app-gallery-app-screenshot-sizes

### Feature/Promo Graphic
- Точные размеры из официальной документации Huawei недоступны без авторизации
- По аналогии с Google Play использовать: **1024 × 500 px** (уточнить в AppGallery Connect)
- Доступно только для приложений с партнёрским соглашением

---

## Категория
- VasoLog: **Health & Fitness** (или аналогичная в AppGallery)
- Два уровня: основная категория + подкатегория
- Должна соответствовать реальной функциональности

---

## Публикация APK

- Формат: **APK** (AppGallery не поддерживает AAB напрямую)
- Подписывание: обычная Android-подпись (тот же keystore что для Google Play)
- VasoLog использует `in_app_review` - на Huawei будет молча отключён (не краш)
- Минимум SDK: android:minSdkVersion="21"

Путь артефактов: `release/v1.1.0/artifacts/` (в .gitignore)

---

## Review Guidelines: Health приложения

### Обязательно
- Дисклеймер: приложение НЕ является медицинским устройством
- Напоминание о консультации с врачом
- Privacy Policy: раскрыть все собираемые данные (для VasoLog - только локальные)
- GDPR-совместимая политика (важно для европейских пользователей)

### Запрещено
- Заявлять что приложение диагностирует, лечит или заменяет медпомощь
- Государственные функции без авторизации от госорганов
- Нарушение авторских прав, мошенничество

### Время ревью
- Обычно **3-5 рабочих дней**
- Первая публикация может занять дольше

---

## Локализация

- AppGallery поддерживает **78+ языков**
- Путь: `release/v1.1.0/metadata/_platform_specific/appgallery/{locale}/`

### Особенности для AppGallery (vs App Store):
1. **Нет keywords.txt** - не загружать
2. **App Name до 64 символов** (App Store = 30, Google Play = 50)
3. **Brief Introduction до 80** = Short Description (совпадает)
4. **Detailed Introduction до 8 000** (App Store и Google Play = 4 000!)
5. **Минимум 3 скриншота** (App Store = 1, Google Play = 2)

---

## Аккаунт разработчика

- Аккаунт: Huawei Developer Console (уже зарегистрирован)
- AppGallery Connect: https://developer.huawei.com/consumer/en/service/josp/agc/index.html
- Тип аккаунта: Individual или Enterprise (для Беларуси работает)
- Монетизация Беларусь: возможна через Payoneer

---

## Источники

- https://phiture.com/asostack/listing-on-appgallery-a-step-by-step-guide-and-a-glance-of-the-developer-console-4dcc6169a7c0/
- https://phiture.com/asostack/huawei-appgallery-search-visibility-6a1a98e9b004/
- https://appradar.com/blog/huawei-app-gallery-app-screenshot-sizes
- https://dev.to/xhunmon/complete-guide-to-creating-an-app-in-appgallery-connect-o81
- https://endlessrunner.co.uk/privacy-policies/huawei-appgallery-review-guidelines
