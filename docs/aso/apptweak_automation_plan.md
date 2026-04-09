# AppTweak - автоматизированный план работы через Playwright MCP

## Статус инструментов
- Playwright MCP установлен: `@playwright/mcp@latest` в `C:\Users\Alex\.claude-account2\.claude.json`
- **Требуется перезапуск Claude Code** для активации `browser_*` инструментов
- Креды: `docs/aso/secrets/apptweak.env` (в .gitignore)

## Что известно про AppTweak (из help.apptweak.com)

### Разделы платформы
1. **Keyword Tool** - research, suggestions, lists, tracker, performance
2. **Analytics** - rankings, downloads, revenues
3. **Store & Creatives Explorer** - live App Store/Google Play insights
4. **Ratings & Reviews** - мониторинг отзывов
5. **Market Intelligence** - тренды рынка
6. **Ad Intelligence** - кто бидит на ключи
7. **Reporting Studio** - кастомные отчёты
8. **Automated Exports** - Slack/email/S3/GCS по расписанию
9. **ASO Agent** (AI) - **только Enterprise tier** → вероятно недоступно на текущем тарифе

### Методы keyword discovery (все доступны для unpublished app)
- **From Competitors** → Top Ranked + Top Installs + Shared/Opportunity табы
- **Live Search / Auto-Complete** - подсказки App Store/Google Play
- **AI Generator (Atlas)** - Discovery/High-Volume Generic/Branded/High-Relevancy
- **Semantic** - 50 related для одного ключа
- **Clusters** - группировка по search intent
- **Category** - топ ключи в категории
- **Trending** (только iOS)

### Метрики
- **Volume** (5-100+), обновлено Feb 2026, multi-country
- **Max. Volume** - исторический максимум с 01.01.2025
- **Difficulty**, **Chance**, **Relevancy**
- Важно: после Feb 2026 многие ключи упали до volume=5 из-за ужесточения reporting threshold App Store → ориентироваться на Max Volume

---

## План исполнения (после перезапуска)

### Фаза 0: Login + разведка интерфейса (5 мин)
1. `browser_navigate` → https://app.apptweak.com/
2. Login: email+password из `apptweak.env`
3. `browser_snapshot` - зафиксировать dashboard, определить **текущий тариф** (от него зависит что доступно)
4. Перечислить доступные разделы меню
5. Сохранить скриншот в `docs/aso/reports/00_dashboard.png`

### Фаза 1: Создание трекаемого app / workspace (5 мин)
VasoLog не опубликован. Варианты:
- a) Если AppTweak позволяет "Draft app" - создать заготовку с временным bundle ID
- b) Если нет - работать через competitor-driven research: все запросы к чужим приложениям
- c) Tracked keyword list без привязки к app (обычно разрешено)

Решение принимается по факту UI. Ожидание: вариант (c) точно сработает.

### Фаза 2: Competitor discovery (15 мин)
Для каждой страны (US, DE, ES, FR, IT, RU):
1. Store Explorer → поиск по seed ключам из `seed_keywords.md`
2. Собрать топ-20 приложений по запросам:
   - "varicose veins" / "varices" / "krampfadern" / "варикоз"
   - "vein health" / "salud venosa"
   - "leg pain diary"
3. Фильтр: есть tracker/diary функционал, >100 отзывов, активны
4. Сохранить shortlist 10-15 конкурентов → `competitors/shortlist.csv`
5. Для топ-5 вытащить: ratings, reviews count, last update, downloads estimate, category

### Фаза 3: Keyword Research (30 мин)
Для каждой страны × основного языка:

**3a. From seeds** - загрузить seed_keywords.md в Keyword List, получить метрики (Volume, Max Vol, Difficulty, Chance) для каждого
**3b. From competitors (Top Ranked + Top Installs)** - для топ-5 конкурентов собрать их ключи, отфильтровать по Volume >= 20
**3c. Opportunity tab** - ключи где конкуренты ранжируются, а VasoLog нет (пока все)
**3d. Semantic expansion** - для топ-10 seed ключей прогнать Semantic → добавить новые с volume >= 20
**3e. AI Generator (Atlas)** - если доступен на тарифе

Финал: объединённый список 100-200 ключей → экспорт CSV → `keywords/{country}_master.csv`

### Фаза 4: Метаданные - черновик (20 мин)
На основе топ-ключей по стране собрать варианты:
- **iOS Title** (30 символов) - 2-3 ключевых термина
- **iOS Subtitle** (30) - дополняющие
- **iOS Keywords field** (100) - без пробелов, запятые
- **Android Title** (30)
- **Android Short description** (80)
- **Android Full description** (до 4000, сфокусированная на top 10 ключей)

Подача в Metadata Simulator AppTweak (если есть) → проверить чтобы keyword stuffing не ломал читабельность.

Сохранить: `reports/metadata_drafts_{country}.md`

### Фаза 5: Экспорт всего что можно (5 мин)
Обойти все разделы, жать Export → сохранить в `apptweak_exports/YYYY-MM-DD/`:
- keyword lists (все страны)
- competitor reports
- category insights
- любые PDF отчёты

### Фаза 6: Итоговый отчёт (10 мин)
`reports/aso_baseline_2026-04-09.md`:
- Текущая конкуренция в нише (сильная/средняя/слабая по странам)
- Топ-20 ключей приоритета по каждой стране
- 5 топ-конкурентов с кратким разбором
- Рекомендуемые metadata drafts
- Риски (category, saturation, seasonality)
- Следующие шаги: трекинг, ретест через 2 недели, A/B на скриншотах

---

## Авто-режим (после baseline)

Через skill `schedule` настроить раз в неделю:
1. Login в AppTweak
2. Обновить позиции VasoLog по tracked keywords (после публикации)
3. Проверить movements конкурентов
4. Новые отзывы у топ-5 → ключевые жалобы → идеи для метаданных
5. Отчёт → `reports/weekly_YYYY-MM-DD.md`
6. Уведомление в Telegram (через telegram skill) если:
   - позиция упала на 10+
   - у конкурента вышел major update
   - появился новый сильный игрок в топ-10
