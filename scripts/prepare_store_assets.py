"""
VasoLog — подготовка store assets для публикации
Версия: 1.1.0 | Апрель 2026

Что делает:
  1. Иконки: App Store 1024×1024 RGB, Google Play 512×512, AppGallery 216×216
  2. Feature Graphic 1024×500 (Google Play + AppGallery)
  3. Скриншоты App Store: letterbox 1260×2844 → 1320×2868
  4. Скриншоты Google Play: копировать лучшие 5 (1260×2844 — принимаются как есть)
  5. Скриншоты AppGallery: те же 5 (min 3 требуется)

Требования:
  pip install Pillow

Запуск из корня проекта:
  py scripts/prepare_store_assets.py
"""

import sys
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import shutil

# ── Пути ──────────────────────────────────────────────────────────────────────
ROOT = Path(__file__).parent.parent
ICON_SRC = ROOT / "assets" / "icon" / "icon.png"
SCREENSHOTS_DIR = ROOT / "screenshots"
OUT = ROOT / "release" / "v1.1.0" / "store_assets"

# ── Цвета приложения (из иконки VasoLog) ──────────────────────────────────────
BG_DARK = (13, 27, 62)        # #0D1B3E — тёмно-синий фон
BG_MID  = (26, 47, 122)       # #1A2F7A — средний синий
ACCENT  = (64, 153, 255)      # #4099FF — акцентный голубой
WHITE   = (255, 255, 255)

# ── Лучшие 5 скриншотов для витрин (по смысловому порядку) ───────────────────
STORE_SCREENSHOTS = [
    ("verify_01_home.png",          "01_home.png"),
    ("verify_02_new_attack.png",    "02_new_attack.png"),
    ("verify_05_finger_selected.png","03_finger_diagram.png"),
    ("verify_02_report.png",        "04_reports.png"),
    ("verify_03_pdf.png",           "05_pdf_export.png"),
]

# App Store iPhone 6.9" (обязательный с 2024)
APPSTORE_W, APPSTORE_H = 1320, 2868


# ── Утилиты ───────────────────────────────────────────────────────────────────

def flatten_rgba(img: Image.Image, bg: tuple) -> Image.Image:
    """RGBA → RGB: альфа-компостинг на фон bg."""
    base = Image.new("RGB", img.size, bg)
    if img.mode == "RGBA":
        base.paste(img, mask=img.split()[3])
    else:
        base.paste(img.convert("RGB"))
    return base


def save_icon(src: Image.Image, path: Path, size: int, rgb: bool = False):
    """Ресайзит и сохраняет иконку. rgb=True — без альфа (App Store)."""
    icon = src.resize((size, size), Image.LANCZOS)
    if rgb:
        icon = flatten_rgba(icon, BG_DARK)
    path.parent.mkdir(parents=True, exist_ok=True)
    icon.save(path, "PNG", optimize=True)
    print(f"  + {path.relative_to(ROOT)}  [{size}×{size}{'  RGB' if rgb else ''}]")


def make_appstore_screenshot(src_path: Path, dst_path: Path):
    """
    Letterbox: 1260×2844 → 1320×2868
    Масштаб по высоте + равные поля по ширине с фоном BG_DARK.
    """
    src = Image.open(src_path)
    scale = APPSTORE_H / src.height                  # 2868 / 2844 ≈ 1.00844
    new_w = round(src.width * scale)                 # 1271 px
    resized = src.resize((new_w, APPSTORE_H), Image.LANCZOS)

    canvas = Image.new("RGB", (APPSTORE_W, APPSTORE_H), BG_DARK)
    x_offset = (APPSTORE_W - new_w) // 2            # ~24 px
    canvas.paste(
        resized.convert("RGB") if resized.mode != "RGB" else resized,
        (x_offset, 0)
    )
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dst_path, "PNG", optimize=True)
    print(f"  + {dst_path.relative_to(ROOT)}  [letterbox {APPSTORE_W}×{APPSTORE_H}]")


def make_feature_graphic(icon_src: Image.Image, dst_path: Path):
    """
    Google Play Feature Graphic: 1024×500 JPEG (требование GP).
    Тёмно-синий градиент слева направо + иконка + текст.
    """
    W, H = 1024, 500
    img = Image.new("RGB", (W, H), BG_DARK)
    draw = ImageDraw.Draw(img)

    # Градиент: горизонтальные полосы BG_DARK → BG_MID
    for x in range(W):
        t = x / W
        r = int(BG_DARK[0] + (BG_MID[0] - BG_DARK[0]) * t)
        g = int(BG_DARK[1] + (BG_MID[1] - BG_DARK[1]) * t)
        b = int(BG_DARK[2] + (BG_MID[2] - BG_DARK[2]) * t)
        draw.line([(x, 0), (x, H)], fill=(r, g, b))

    # Тонкая акцентная полоса снизу
    draw.rectangle([(0, H - 4), (W, H)], fill=ACCENT)

    # Иконка: 200×200, левый центр, отступ 60px
    ICON_SIZE = 200
    icon_rgb = flatten_rgba(icon_src.resize((ICON_SIZE, ICON_SIZE), Image.LANCZOS), BG_DARK)
    icon_x, icon_y = 60, (H - ICON_SIZE) // 2
    img.paste(icon_rgb, (icon_x, icon_y))

    # Шрифты (Segoe UI — нативный Windows, хорошо выглядит)
    font_path = "C:/Windows/Fonts/segoeui.ttf"
    try:
        font_title    = ImageFont.truetype(font_path, 72)
        font_subtitle = ImageFont.truetype(font_path, 28)
        font_tag      = ImageFont.truetype(font_path, 22)
    except Exception:
        font_title = font_subtitle = font_tag = ImageFont.load_default()

    text_x = icon_x + ICON_SIZE + 60   # правее иконки

    # Название
    draw.text((text_x, 110), "VasoLog", font=font_title, fill=WHITE)

    # Слоган
    draw.text(
        (text_x, 200),
        "Raynaud's Tracker",
        font=font_subtitle,
        fill=ACCENT,
    )

    # Описание (2 строки)
    draw.text(
        (text_x, 248),
        "Track episodes · Weather data · PDF reports",
        font=font_tag,
        fill=(180, 200, 240),
    )
    draw.text(
        (text_x, 278),
        "Communicate clearly with your doctor",
        font=font_tag,
        fill=(150, 175, 220),
    )

    dst_path.parent.mkdir(parents=True, exist_ok=True)
    # JPEG качество 95 — Google Play принимает JPEG или PNG
    img.save(dst_path, "JPEG", quality=95, optimize=True)
    print(f"  + {dst_path.relative_to(ROOT)}  [1024×500 JPEG]")


# ── Основной скрипт ───────────────────────────────────────────────────────────

def main():
    print("\n=== VasoLog Store Assets ===\n")

    icon_src = Image.open(ICON_SRC).convert("RGBA")

    # 1. Иконки
    print("[ 1/4 ] Иконки")
    save_icon(icon_src, OUT / "icons" / "appstore_1024x1024.png",  1024, rgb=True)
    save_icon(icon_src, OUT / "icons" / "googleplay_512x512.png",   512, rgb=False)
    save_icon(icon_src, OUT / "icons" / "appgallery_216x216.png",   216, rgb=False)

    # 2. Feature Graphic
    print("\n[ 2/4 ] Feature Graphic (Google Play / AppGallery)")
    make_feature_graphic(icon_src, OUT / "feature_graphic" / "feature_1024x500.jpg")

    # 3. Скриншоты App Store (letterbox → 1320×2868)
    print("\n[ 3/4 ] Скриншоты — App Store (1320×2868 letterbox)")
    for src_name, dst_name in STORE_SCREENSHOTS:
        src = SCREENSHOTS_DIR / src_name
        if not src.exists():
            print(f"  - {src_name} — не найден, пропускаю")
            continue
        make_appstore_screenshot(src, OUT / "screenshots" / "appstore" / dst_name)

    # 4. Скриншоты Google Play + AppGallery (1260×2844 — принимаются как есть)
    print("\n[ 4/4 ] Скриншоты — Google Play + AppGallery (1260×2844, as-is)")
    for src_name, dst_name in STORE_SCREENSHOTS:
        src = SCREENSHOTS_DIR / src_name
        if not src.exists():
            print(f"  - {src_name} — не найден, пропускаю")
            continue
        for store in ("google_play", "appgallery"):
            dst = OUT / "screenshots" / store / dst_name
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            print(f"  + {dst.relative_to(ROOT)}")

    # 5. Итоговый отчёт
    print("\n=== Готово ===")
    print(f"Папка: {OUT.relative_to(ROOT)}\n")
    for f in sorted(OUT.rglob("*")):
        if f.is_file():
            size_kb = f.stat().st_size // 1024
            print(f"  {f.relative_to(OUT)}  ({size_kb} KB)")

    print("""
СЛЕДУЮЩИЕ ШАГИ:
  App Store    → Загрузить в App Store Connect: icons/appstore_1024x1024.png
                 Скриншоты: screenshots/appstore/*.png (iPhone 6.9")
  Google Play  → icons/googleplay_512x512.png + feature_graphic/feature_1024x500.jpg
                 Скриншоты: screenshots/google_play/*.png
  AppGallery   → icons/appgallery_216x216.png + feature_graphic/feature_1024x500.jpg
                 Скриншоты: screenshots/appgallery/*.png (min 3)
""")


if __name__ == "__main__":
    main()
