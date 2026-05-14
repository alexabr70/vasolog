# VasoLog - Google Play UI Playbook (то что нельзя через API)

**Дата:** 2026-05-14
**Цель:** заполнить за 30-45 минут все формы Console UI с точными ответами.
**Источник:** Play Console UI, https://play.google.com/console → VasoLog

⚠️ Откроется на русском (UI Алекса).

---

## Раздел "Политика" → "Контент приложения"

Левое меню: **Политика → Контент приложения** (или Policy → App Content)

### 1. Политика конфиденциальности (Privacy Policy)
- Кнопка "Управление" → "Добавить политику конфиденциальности"
- **URL:** `https://alexabr70.github.io/vasolog/privacy_policy.html`
- Save

### 2. Доступ к приложению (App Access)
- "Управление" → "Без ограничений на доступ" (All functionality is available without special access)
- Save

### 3. Реклама (Ads)
- "Нет, моё приложение не содержит рекламу" (No, my app does not contain ads)
- Save

### 4. Возрастной рейтинг (Content Rating - IARC questionnaire)
- "Запустить опросник" → "Начать"
- **Контактный email:** `vika.abr71@gmail.com`
- **Категория приложения:** `Reference, News, or Educational` (НЕ Games)

Опросник (все ответы НЕТ кроме указанных):
- Violence: **No**
- Sexual content: **No**
- Profanity/crude humor: **No**
- Controlled substances: **No**
- Simulated gambling: **No**
- Real money gambling: **No**
- Horror/fear-inducing content: **No**
- User-generated content: **No** (нет соцфункций)
- Sharing user location: **No** (для weather только, не social sharing)
- Sharing user's personal info to third parties: **Yes** (location → OpenWeatherMap; analytics → Firebase)
- Digital purchases: **No**
- Unrestricted internet: **Yes** (weather API)
- Discrimination: **No**

→ Результат: скорее всего **PEGI 3 / IARC 3+ / Everyone**
- Save → Apply rating

### 5. Целевая аудитория и контент (Target Audience and Content)
- **Возрастные группы:**
  - Снять галочку с детских (Ages 5 and under, Ages 6-8, Ages 9-12)
  - Поставить: **Ages 13-15, Ages 16-17, Ages 18 and over**
- "Это приложение **не привлекательно** для детей" (does not appeal to children)
- Save

### 6. Новостное приложение
- **Нет** (not a news app)

### 7. Отслеживание COVID-19
- **Нет** (not a COVID tracing/status app)

### 8. Правительственное приложение
- **Нет** (not a government app)

### 9. Финансовые функции
- **Нет** (no financial services)

### 10. Безопасность данных (Data Safety)
**ОПЦИЯ A - быстрая (1 минута):**
- "Управление" → меню "..." (три точки) → **"Экспорт CSV"**
- Сохранить .csv файл, прислать мне путь
- Я заполню по [google_play_data_safety.md](./google_play_data_safety.md) и POST через API

**ОПЦИЯ B - вручную в UI (15 минут):**
- "Запустить опросник Data Safety"
- Все ответы строго по [google_play_data_safety.md](./google_play_data_safety.md)
- Главное: 6 категорий со значением "Yes" (Approximate location, Health info, Photos, App interactions, Crash logs, Diagnostics, Device IDs), остальные 8 - "No"

### 11. Декларация для приложений в области здоровья (Health Apps Declaration)
- "Управление" → "Запустить"
- Опросник:
  - Provides medical diagnosis? **No**
  - Provides treatment recommendations? **No**
  - Is a medical device? **No**
  - Provides telemedicine/teleconsultation services? **No**
  - Provides prescription services? **No**
  - Stores PHI (Protected Health Information)? **No** (всё локально)
  - Intended for medical professionals? **No** (для пациентов)
  - Body measurement/vital signs features? **No** (manual logs only)
  - Mental health features? **No** (это symptom tracker для Raynaud's)
- Purpose statement: **"Symptom tracking for personal wellness and information sharing with medical providers"**
- Save

---

## Раздел "Магазин" → "Основная информация" (Store Settings → Main Store Listing)

### 12. Категория приложения
- App category: **Health & Fitness** (НЕ Medical - для Personal account это правильнее)
- Email: `vika.abr71@gmail.com`
- Website: `https://alexabr70.github.io/vasolog/`
- Phone: пусто (опционально)

### 13. Теги (до 5)
- `Symptom Tracker`
- `Health Diary`
- `Chronic Disease`
- `Wellness Tracking`
- `Weather Log`

(Точные теги могут отличаться - Console предлагает список, выбирай ближайшие)

---

## Раздел "Распространение" → "Цена и распространение" (Pricing & Distribution)

### 14. Цена
- **Бесплатно** (Free)

### 15. Страны и регионы
- Нажать "Управление странами" → "Добавить все доступные страны" (Add all countries)
- ИЛИ выбрать как AppGallery: ~150 стран (Asia, Europe, Americas, Africa - кроме санкционных территорий)
- Save

---

## Раздел "Тестирование" → "Закрытое тестирование" → "Альфа"

### 16. Тестеры
- Вкладка "Тестеры" → "Создать список адресов электронной почты"
- Имя списка: `VasoLog Closed Testers`
- Email-адреса (минимум 12, по мере сбора через Reddit):
  ```
  alex@example.com
  tester1@gmail.com
  ...
  ```
- Save

### 17. Каналы обратной связи
- Feedback email: `vika.abr71@gmail.com`

### 18. Запуск (после заполнения всех форм + 12+ testers)
- Вкладка "Релизы" → "Просмотреть и развернуть"
- Альфа release ждёт активации (v1.1.3 build 10)
- Confirm → Roll out

---

## Финальный чеклист (проверь перед roll out)

- [ ] Privacy Policy URL добавлен
- [ ] App Access = Without restrictions
- [ ] Ads = No ads
- [ ] Content Rating заполнен (получен PEGI/IARC rating)
- [ ] Target Audience = 13+
- [ ] News/COVID/Government/Financial = все No
- [ ] Data Safety заполнена (через API или UI)
- [ ] Health Apps Declaration = wellness tracker, не medical device
- [ ] Категория = Health & Fitness
- [ ] Теги (5) добавлены
- [ ] Цена = Free
- [ ] Страны = выбраны (минимум default)
- [ ] Список тестеров создан (минимум 12 email)

Когда все галки → Roll out alpha → 14 дней ожидания → Production.
