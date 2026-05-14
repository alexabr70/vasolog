"""
VasoLog screenshots v7 - Google Play 2026 best practices.

Style:
- БЕЗ phone frame (Google прямо рекомендует "Avoid device imagery")
- БЕЗ rotation (anti-pattern 2026)
- Light background (#FFFFFF clean) - Google Play тяготеет к light
- Top 25% = headline + subhead (text ≤20% площади по Google guideline)
- Bottom 75% = full UI screenshot, centered, с subtle shadow
- Purple #5E35B1 для headline (brand color = дифференциатор)
- Размер: 1260×2240 (9:16, в лимитах Google)

Output: D:/dev/vasolog/release/v1.1.4/store_assets/google_play/screenshots/{lang}/{name}.png

Source raw screenshots:
  D:/dev/vasolog/release/v1.1.0/store_assets/appgallery/raw/{lang}/0X_*.png (1260×2844)

Headlines:
  D:/dev/vasolog/scripts/headlines_v3.json (18 локалей × 6 экранов с native переводами)

Скрипты для шрифтов:
  - Latin/Cyrillic: Segoe UI (Windows стандарт, поддерживает en/ru/de/fr/es/it/pt/sv/nl/no/da/fi/hu/pl/cs/uk)
  - Japanese: Yu Gothic (Windows стандарт)
  - Korean: Malgun Gothic (Windows стандарт)
"""
import io
import json
import sys
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(r"D:/dev/vasolog")
RAW_DIR = ROOT / "release/v1.1.0/store_assets/appgallery/raw"
HEADLINES = ROOT / "scripts/headlines_v3.json"
OUT_DIR = ROOT / "release/v1.1.4/store_assets/google_play/screenshots"

# Какие 5 скринов из 6 берём (Hook → Speed → Unique → Insight → Trust)
SCREENS = [
    ("01_home", "01_home"),         # Hook
    ("02_add_top", "02_speed"),     # Speed
    ("03_add_hands", "03_unique"),  # Unique feature (hand diagram)
    ("04_history", "04_insight"),   # Medical credibility
    ("06_report", "05_doctor"),     # Trust (PDF for doctor)
]

# Output canvas
CANVAS_W = 1260
CANVAS_H = 2240
BG_COLOR = (255, 255, 255)          # White background

# Headline area (top 25%)
HEADLINE_TOP = 80
HEADLINE_COLOR = (94, 53, 177)      # Purple #5E35B1 (deep)
SUBHEAD_COLOR = (96, 96, 96)        # Gray #606060

# UI area (bottom 75%)
UI_TOP = 480                         # 21% от top - меньше gap до headline
UI_BOTTOM = CANVAS_H - 30           # 30px нижний padding

# Crop raw screenshot - убираем Huawei status bar и system navigation
RAW_CROP_TOP = 145                  # Status bar Huawei (часы, иконки) + notch zone
RAW_CROP_BOTTOM = 200               # System navigation + gesture bar Huawei

# Subtle device outline (лёгкий mockup без полного frame)
BORDER_WIDTH = 3                    # Толщина обводки UI (px)
BORDER_COLOR = (210, 210, 220)      # Светло-серый, чуть холодный
BORDER_RADIUS = 36                  # Скругление углов "экрана"

# Fonts
FONT_LATIN_BOLD = r"C:/Windows/Fonts/segoeuib.ttf"
FONT_LATIN_REG = r"C:/Windows/Fonts/segoeui.ttf"
FONT_JA_BOLD = r"C:/Windows/Fonts/YuGothB.ttc"
FONT_JA_REG = r"C:/Windows/Fonts/YuGothM.ttc"
FONT_KO_BOLD = r"C:/Windows/Fonts/malgunbd.ttf"
FONT_KO_REG = r"C:/Windows/Fonts/malgun.ttf"

# Font size
HEADLINE_SIZE = 96
SUBHEAD_SIZE = 42


def get_fonts(lang: str) -> tuple[ImageFont.FreeTypeFont, ImageFont.FreeTypeFont]:
    """Подбор шрифтов по локали."""
    if lang == "ja":
        bold = ImageFont.truetype(FONT_JA_BOLD, HEADLINE_SIZE)
        reg = ImageFont.truetype(FONT_JA_REG, SUBHEAD_SIZE)
    elif lang == "ko":
        bold = ImageFont.truetype(FONT_KO_BOLD, HEADLINE_SIZE)
        reg = ImageFont.truetype(FONT_KO_REG, SUBHEAD_SIZE)
    else:
        bold = ImageFont.truetype(FONT_LATIN_BOLD, HEADLINE_SIZE)
        reg = ImageFont.truetype(FONT_LATIN_REG, SUBHEAD_SIZE)
    return bold, reg


def draw_text_centered(draw: ImageDraw.ImageDraw, text: str, y: int,
                        font: ImageFont.FreeTypeFont, color: tuple,
                        line_spacing: int = 12) -> int:
    """Рисует multi-line text по центру, возвращает Y после блока."""
    lines = text.split("\n")
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        x = (CANVAS_W - w) // 2
        draw.text((x, y), line, fill=color, font=font)
        y += h + line_spacing
    return y


def composite_screenshot(raw_path: Path, headline: str, subhead: str,
                          out_path: Path, lang: str) -> None:
    """Создаёт один screenshot v7."""
    # 1. Canvas
    canvas = Image.new("RGB", (CANVAS_W, CANVAS_H), BG_COLOR)
    draw = ImageDraw.Draw(canvas)

    # 2. Headlines
    font_bold, font_reg = get_fonts(lang)
    y_after_headline = draw_text_centered(draw, headline, HEADLINE_TOP, font_bold, HEADLINE_COLOR)
    draw_text_centered(draw, subhead, y_after_headline + 30, font_reg, SUBHEAD_COLOR)

    # 3. Raw UI screenshot - fit в UI area, keeping aspect
    raw = Image.open(raw_path).convert("RGB")
    # Crop статус-бар сверху и system navigation снизу (Huawei specific)
    raw = raw.crop((0, RAW_CROP_TOP, raw.size[0], raw.size[1] - RAW_CROP_BOTTOM))
    raw_w, raw_h = raw.size

    ui_area_h = UI_BOTTOM - UI_TOP   # 1600px высота
    ui_area_w = CANVAS_W - 200        # 1060px ширина (с боковыми padding)

    # Scale by height (raw обычно вытянут)
    scale = ui_area_h / raw_h
    new_w = int(raw_w * scale)
    new_h = ui_area_h
    if new_w > ui_area_w:
        scale = ui_area_w / raw_w
        new_w = ui_area_w
        new_h = int(raw_h * scale)

    raw_resized = raw.resize((new_w, new_h), Image.LANCZOS)

    # 4. Усиленный shadow под UI (floating depth)
    shadow_offset_x = 0
    shadow_offset_y = 14
    shadow_padding = 60
    shadow = Image.new("RGBA", (new_w + shadow_padding * 2, new_h + shadow_padding * 2), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        (shadow_padding, shadow_padding, shadow_padding + new_w, shadow_padding + new_h),
        radius=BORDER_RADIUS,
        fill=(60, 40, 100, 70),   # Слегка фиолетовый shadow для brand mood
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))

    # 5. Paste shadow
    ui_x = (CANVAS_W - new_w) // 2
    ui_y = UI_TOP + (ui_area_h - new_h) // 2
    canvas.paste(
        shadow,
        (ui_x - shadow_padding + shadow_offset_x, ui_y - shadow_padding + shadow_offset_y),
        shadow,
    )

    # 6. Round corners на UI
    mask = Image.new("L", (new_w, new_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle((0, 0, new_w, new_h), radius=BORDER_RADIUS, fill=255)
    canvas.paste(raw_resized, (ui_x, ui_y), mask)

    # 7. Лёгкая subtle обводка границы "экрана" (без полного mockup)
    border_draw = ImageDraw.Draw(canvas)
    border_draw.rounded_rectangle(
        (ui_x, ui_y, ui_x + new_w - 1, ui_y + new_h - 1),
        radius=BORDER_RADIUS,
        outline=BORDER_COLOR,
        width=BORDER_WIDTH,
    )

    # 6. Save
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path, "PNG", optimize=True)


def main(langs: list[str] | None = None) -> int:
    headlines_data = json.loads(HEADLINES.read_text(encoding="utf-8"))["headlines"]

    if langs is None:
        langs = sorted(headlines_data.keys())

    total = 0
    skipped = 0
    for lang in langs:
        if lang not in headlines_data:
            print(f"  SKIP {lang}: нет в headlines_v3.json")
            skipped += 1
            continue
        lang_data = headlines_data[lang]
        raw_lang_dir = RAW_DIR / lang
        if not raw_lang_dir.exists():
            print(f"  SKIP {lang}: нет raw папки {raw_lang_dir}")
            skipped += 1
            continue

        for raw_name, out_name in SCREENS:
            if raw_name not in lang_data:
                print(f"  SKIP {lang}/{raw_name}: нет headline")
                continue
            headline = lang_data[raw_name]["headline"]
            subhead = lang_data[raw_name]["subhead"]
            raw_path = raw_lang_dir / f"{raw_name}.png"
            if not raw_path.exists():
                print(f"  SKIP {lang}/{raw_name}: нет raw файла")
                continue
            out_path = OUT_DIR / lang / f"{out_name}.png"
            composite_screenshot(raw_path, headline, subhead, out_path, lang)
            total += 1
            print(f"  OK   {lang}/{out_name}.png")

    print()
    print(f"Готово: {total} файлов, пропущено: {skipped}")
    return 0


if __name__ == "__main__":
    # CLI: python make_screenshots_v7.py [lang1 lang2 ...]
    langs_arg = sys.argv[1:] if len(sys.argv) > 1 else None
    sys.exit(main(langs_arg))
