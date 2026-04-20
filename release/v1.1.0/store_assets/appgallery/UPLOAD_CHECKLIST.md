# VasoLog AppGallery - Upload Checklist (Phase 1)

**Источник файлов:** `D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/upload_packages/_extracted/{lang}/`
**Локалей:** 18 × 6 PNG = 108 файлов
**Ожидаемое время:** 20-30 мин

---

## Навигация (делать 1 раз)

1. https://developer.huawei.com/consumer/en/service/josp/agc/index.html → Sign in
2. **My Apps** → выбрать **VasoLog**
3. **Distribute** → **App Information**
4. Scroll до секции **Media Resources** → **Phone Screenshots**

## Порядок действий (для каждой локали)

1. Переключатель языка вверху страницы → выбрать локаль (таблица ниже)
2. В Phone Screenshots нажать **Upload** / **Add**
3. Открыть Explorer в папке: `D:\DEV\vasolog\release\v1.1.0\store_assets\appgallery\upload_packages\_extracted\{lang}\`
4. Выделить ВСЕ 6 PNG (Ctrl+A) → перетащить в браузер ИЛИ выбрать по одному
5. Проверить порядок: `01_home` → `02_add_top` → `03_add_hands` → `04_history` → `05_add_bottom` → `06_report`
6. **Save** (важно! без сохранения локаль не зафиксируется)
7. Переключить на следующий язык

## Чеклист локалей

Заливать в этом порядке (en первым - это default fallback):

- [ ] **en** - English (default)
- [ ] **de** - Deutsch
- [ ] **fr** - Français
- [ ] **es** - Español
- [ ] **it** - Italiano
- [ ] **pt** - Português
- [ ] **nl** - Nederlands
- [ ] **pl** - Polski
- [ ] **cs** - Čeština
- [ ] **hu** - Magyar
- [ ] **sv** - Svenska
- [ ] **da** - Dansk
- [ ] **nb** - Norsk Bokmål *(в AppGallery может называться "Norwegian")*
- [ ] **fi** - Suomi
- [ ] **ru** - Русский
- [ ] **uk** - Українська
- [ ] **ja** - 日本語
- [ ] **ko** - 한국어

## Частые грабли

- **Порядок 1-6 важен** - AppGallery показывает скриншоты в порядке upload, первый = hero shot
- **Save после каждой локали** - иначе при переключении языка несохранённое теряется
- **Если нет вкладки языка** → App Information → Languages → Add Language
- **Ошибка "resolution too small"** - проверить что открываешь PNG из `_extracted/`, не из ZIP
- **Размер OK** (макс 1.09 MB, лимит 2 MB) - не должно быть ошибок

## После всех 18

- [ ] В AppGallery Console визуально проверить 3-4 локали случайно (en, ja, ru, de)
- [ ] Submit for review (если всё ок) ИЛИ оставить в Draft до доукомплектации

---

**Статус:** Phase 1 assets готовы, ждут ручной заливки.
**Next:** после submit → мониторить review (3-5 дней по docs).
