"""
Скрипт для исправления иконки VasoLog.
Убирает встроенные скругления - заполняет прозрачные/полупрозрачные углы
фоновым цветом (тёмно-синий из фона иконки).
iOS сам добавит squircle скругление поверх.
"""

from PIL import Image
import shutil
from pathlib import Path

ICON_PATH = Path(__file__).parent.parent / "assets" / "icon" / "icon.png"
BACKUP_PATH = ICON_PATH.with_suffix(".backup.png")
# Тёмно-синий фон из иконки
BG_COLOR = (13, 27, 62, 255)  # #0D1B3E


def fix_icon():
    img = Image.open(ICON_PATH).convert("RGBA")

    # Бэкап
    shutil.copy2(ICON_PATH, BACKUP_PATH)
    print(f"Бэкап: {BACKUP_PATH}")

    pixels = img.load()
    w, h = img.size
    filled = 0

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            # Прозрачные и полупрозрачные пиксели заполняем фоном
            if a < 200:
                # Смешиваем с фоном пропорционально альфе
                alpha_ratio = a / 255.0
                nr = int(r * alpha_ratio + BG_COLOR[0] * (1 - alpha_ratio))
                ng = int(g * alpha_ratio + BG_COLOR[1] * (1 - alpha_ratio))
                nb = int(b * alpha_ratio + BG_COLOR[2] * (1 - alpha_ratio))
                pixels[x, y] = (nr, ng, nb, 255)
                filled += 1

    img.save(ICON_PATH)
    print(f"Исправлено {filled} пикселей из {w * h}")
    print(f"Сохранено: {ICON_PATH}")


if __name__ == "__main__":
    fix_icon()
