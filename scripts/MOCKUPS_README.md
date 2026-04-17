# Premium App Store Mockup Generator v3

Генератор профессиональных мокапов для App Store уровня Apple/Headspace/Calm 2026.

## Установка

```bash
pip install pillow numpy scipy
```

## Использование

### Генерировать все EN мокапы (6 скриншотов)

```bash
python make_mockups_v3.py
```

### Добавить новый язык

1. Добавить переводы в `HEADLINES` словарь (или `USP_BADGES` если нужны бейджи):

```python
HEADLINES = {
    "en": { ... },
    "ru": {
        "01_home": ("Твой Рейно,\nрасшифрован.", "Погода, атаки, триггеры — одно место"),
        # ... остальные 5 скриншотов
    },
}
```

2. Убедиться что raw скриншоты есть в `raw/ru/*.png`

3. Вызвать функцию:

```python
from make_mockups_v3 import make_mockup

# Для одного скриншота:
make_mockup("ru", "01_home", "Твой Рейно,\nрасшифрован.", "Погода, атаки, триггеры — одно место")

# Или создать функцию generate_all_LANG_mockups() и вызвать её
```

## Структура кода

- `create_gradient_canvas()` - фон (3-цветный градиент + шум)
- `draw_phone_frame()` - iPhone 16 Pro frame с Dynamic Island
- `add_glass_reflection()` - стеклянная рефлексия на экране
- `add_shadow_below_phone()` - тень под телефоном
- `draw_text_headline()` - большой заголовок (100px)
- `draw_text_subhead()` - описание (48px)
- `draw_usp_badge()` - оранжевый бейдж (только для 03_add_hands)
- `make_mockup()` - основная функция генерации одного мокапа

## Параметры дизайна

| Параметр | Значение |
|----------|----------|
| Canvas | 1260×2798px (9:19.5) |
| Screen | 1100×2245px (внутри frame) |
| Gradient | #1A0F3A → #5E35B1 → #7C3AED |
| Noise | 4.5% opacity |
| Frame | Titanium Dark #3A3A3C, radius 72px |
| Dynamic Island | 360×115px, radius 57px |
| Glass Reflection | 40% opacity, GaussianBlur 40px |
| Shadow | GaussianBlur 40px, offset +30px Y |
| Headline Font | Segoe UI Bold 100px, line-height 1.12 |
| Subhead Font | Segoe UI Regular 48px, line-height 1.25 |
| USP Badge | #FF7043 Orange, 42px, padding 34×14px |

## Выход

PNG файлы в `mockups_v3/{lang}/{screen}.png`

Размер: ~600-1300KB в зависимости от content complexity
