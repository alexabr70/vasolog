# VasoLog AppGallery - Phase 2-4 Roadmap

После Phase 1 (18 языков, 108 mockups) - расширение на новые рынки.

## Phase 2: Turkish + Arabic (TR, AR)

**Рынок:** Turkey 85M + GCC (Saudi 35M + UAE 10M + Egypt 110M = 155M).
Raynaud prevalence в холодных регионах Турции высокая, арабский рынок - premium medical apps.

**Задачи:**
1. Локализация app UI (tr.json, ar.json) - ~500 строк каждая
2. **RTL поддержка** для арабского (AR) - критично: проверить Flutter Directionality
3. Скриншоты: 6 screens × 2 langs = 12 raw PNG
4. Headlines + native audit (турецкий: носитель из Стамбула; арабский: MSA не диалект)
5. USP badges: TR "ÖZGÜN", AR "حصري"
6. Mockups generation (добавить fonts: Noto Sans Arabic, Noto Sans Turkish в FONT_STACK)
7. AppGallery listing translations (description, title, keywords)

**Риски:**
- AR RTL layout может сломать hand-tap UI на 03_add_hands
- Medical терминология на AR: использовать словарь Unified Medical Dictionary (WHO)

**Оценка:** 3-4 часа (основная работа - native audit + RTL тестирование)

---

## Phase 3: Southeast Asia + India (ID, VI, TH, HI)

**Рынок:** Indonesia 275M + Vietnam 100M + Thailand 70M + India 1.4B = **1.85B**.
Стратегия: медленный ROI на user, но массовый охват. Freemium model с ценой в local currency.

**Задачи:**
1. Локализация UI × 4 языков (id, vi, th, hi)
2. Скриншоты: 6 × 4 = 24 raw PNG
3. Headlines + native audit:
   - ID: bahasa baku, не slang
   - VI: Hà Nội dialect (стандарт), диакритика обязательна
   - TH: ต้องมีวรรณยุกต์ถูกต้อง (тональность критична)
   - HI: देवनागरी, избегать urdu-заимствований
4. **Fonts:** Noto Sans Thai (для TH особенно), Noto Sans Devanagari (HI), стандарт для ID/VI
5. USP badges: ID "UNIK", VI "ĐỘC QUYỀN", TH "เฉพาะที่นี่", HI "केवल यहाँ"
6. **TH особенность:** длинные слова без пробелов - headline может не влезть. Использовать 3 строки.

**Риски:**
- TH/HI ascenders+descenders требуют больше line-height (обычно 1.4 вместо 1.08)
- Monetization: ARPU в India/ID низкая - рассмотреть subscription $0.99/mo tier

**Оценка:** 6-8 часов (native audit самый долгий для THAI и HI)

---

## Phase 4: China (zh-CN) - Licensing Track

**Рынок:** China 1.4B, 2nd largest Android market after India.
AppGallery в Китае - отдельный bucket (Huawei China региональное отделение).

**Блокеры:**
1. **ICP licensing** - обязателен для apps с user data, весь backend должен быть в Китае
2. Medical app certification (Class II medical device в China classification)
3. **Personal Information Protection Law (PIPL)** - аналог GDPR, строгие требования
4. AppGallery China требует Chinese legal entity (WFOE) или partnership с местным publisher

**Шаги (6-12 месяцев):**
1. Юридический аудит: нужен ли ICP для нашего use case (только local storage attack data - возможно НЕ нужен)
2. Если backend required → migrate к Alibaba Cloud / Tencent Cloud inside China
3. Medical certification через State Drug Administration (NMPA)
4. Локализация zh-CN (Simplified Chinese) - native audit от Beijing/Shanghai speaker
5. AppGallery China submission через Huawei Developer China account

**Альтернатива:** не делать Phase 4, остановиться на Phase 1-3 (18+6=24 языка уже покрывают 4B+ населения).

**Оценка:** 6-12 месяцев + юридические расходы $5-15k, ROI неочевиден для бесплатной медицинской утилиты.

---

## Итого по фазам

| Phase | Languages | New markets | Time | Blockers |
|-------|-----------|-------------|------|----------|
| 1 (DONE) | 18 | Europe + JP/KR | - | - |
| 2 | +2 (tr, ar) | Turkey + GCC | 3-4h | RTL layout |
| 3 | +4 (id, vi, th, hi) | SEA + India | 6-8h | Font rendering TH/HI |
| 4 | +1 (zh-CN) | China | 6-12mo | ICP + NMPA licensing |

## Рекомендация

1. **Phase 2** (TR+AR) - запустить в следующей сессии, ROI высокий (premium market)
2. **Phase 3** (SEA+HI) - когда закрыт Phase 2 и есть baseline метрики
3. **Phase 4** (CN) - отложить до revenue proof (не раньше v1.5)

---

## Технический долг (vs v5)

- USP glow на CJK языках "прилипает" к phone frame top (оптически) - косметика, не критично
- Font fallback: Segoe UI → Yu Gothic/Malgun - работает на Windows, но если генерить на macOS/Linux нужен Noto Sans CJK
- Нет automation для native audit (делается вручную)
- mockups_final/ коммитится в git (66MB) - при росте до 24 языков станет ~150MB, тогда перенести в Git LFS

---

Last updated: 2026-04-17 (commit 883c6e1)
