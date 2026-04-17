#!/usr/bin/env py
"""
VasoLog - снять 6 скриншотов × 18 языков = 108 изображений для AppGallery.

Подход: UI Automator даёт точные bounds кнопок (включая пальцы в hand illustrations),
поэтому тапы работают независимо от scroll-позиции.

Reference: D:/скрины/ (6 JPG от Alex'а на русском)
Output:    D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw/{lang}/0{1-6}_*.png
"""

import subprocess
import time
import xml.etree.ElementTree as ET
import re
import os
import sys
import io
from pathlib import Path

# Force UTF-8 stdout on Windows (для корректного вывода CJK/кириллицы)
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace", line_buffering=True)
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace", line_buffering=True)

ADB = "D:/dev/AndroidSDK/platform-tools/adb.exe"
PKG = "com.vasolog.app"
TMP_UI = "/sdcard/ui.xml"

OUT_DIR = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw")
OUT_DIR.mkdir(parents=True, exist_ok=True)

LANG_PICKER_IDX = {
    "en": 1, "ru": 2, "de": 3, "fr": 4, "es": 5, "pt": 6,
    "it": 7, "sv": 8, "fi": 9, "nb": 10, "da": 11, "nl": 12,
    "pl": 13, "cs": 14, "hu": 15, "uk": 16, "ja": 17, "ko": 18,
}

# Native display names в picker - используем их как accessibility desc для bulletproof тапа
LANG_NATIVE_NAME = {
    "en": "English",
    "ru": "Русский",
    "de": "Deutsch",
    "fr": "Français",
    "es": "Español",
    "pt": "Português",
    "it": "Italiano",
    "sv": "Svenska",
    "fi": "Suomi",
    "nb": "Norsk",
    "da": "Dansk",
    "nl": "Nederlands",
    "pl": "Polski",
    "cs": "Čeština",
    "hu": "Magyar",
    "uk": "Українська",
    "ja": "日本語",
    "ko": "한국어",
}

# ── ADB primitives ───────────────────────────────────────────────────────────

def adb(*args, **kw):
    return subprocess.run([ADB, *args], capture_output=True, text=True, **kw)

def shell(cmd, binary=False):
    res = subprocess.run([ADB, "shell", cmd], capture_output=True)
    return res.stdout if binary else res.stdout.decode("utf-8", errors="replace")

def shell_bin(cmd):
    """Сохраняем вывод adb shell как бинарь (для screencap)."""
    return subprocess.run([ADB, "exec-out", cmd], capture_output=True).stdout

def tap(x, y, wait=0.5):
    shell(f"input tap {x} {y}")
    time.sleep(wait)

def swipe(x1, y1, x2, y2, dur=400, wait=1.0):
    shell(f"input swipe {x1} {y1} {x2} {y2} {dur}")
    time.sleep(wait)

def back(wait=1.2):
    shell("input keyevent 4")
    time.sleep(wait)

def screencap(path):
    data = shell_bin("screencap -p")
    Path(path).write_bytes(data)

def focused_pkg():
    out = shell("dumpsys window | grep mCurrentFocus")
    m = re.search(r"(com\.[a-zA-Z0-9_.]+|by\.[a-zA-Z0-9_.]+|org\.[a-zA-Z0-9_.]+)", out)
    return m.group(1) if m else ""

def ensure_vasolog():
    if PKG in focused_pkg():
        return True
    print(f"  [recover] focus={focused_pkg()!r}, launching {PKG}")
    shell(f"monkey -p {PKG} -c android.intent.category.LAUNCHER 1")
    time.sleep(2.5)
    # back куда-то если pop-up
    for _ in range(3):
        if PKG in focused_pkg():
            return True
        back(0.8)
    return PKG in focused_pkg()

# ── UI Automator парсинг ─────────────────────────────────────────────────────

def dump_ui():
    shell(f"uiautomator dump {TMP_UI}")
    xml_str = subprocess.run([ADB, "shell", f"cat {TMP_UI}"],
                             capture_output=True).stdout.decode("utf-8", errors="replace")
    return xml_str

def bounds_center(bounds_str):
    m = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", bounds_str)
    if not m:
        return None
    x1, y1, x2, y2 = map(int, m.groups())
    return (x1 + x2) // 2, (y1 + y2) // 2

def find_finger_buttons(xml_str):
    """Возвращает список (cx, cy) всех 'Палец: *' button'ов.
    Первые 5 - левая рука (по y возрастанию внутри группы), следующие 5 - правая."""
    root = ET.fromstring(xml_str)
    fingers = []
    for node in root.iter("node"):
        desc = node.attrib.get("content-desc", "")
        # Content-desc в dump приходит в encoded UTF-8 или cp1251. Проверим что это палец
        # по признаку: длина ~15-25 символов и наличие "Пал" (byte sequence differs)
        # Проще по двоеточию + bounds size ~160x160
        bounds = node.attrib.get("bounds", "")
        m = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", bounds)
        if not m:
            continue
        x1, y1, x2, y2 = map(int, m.groups())
        w, h = x2 - x1, y2 - y1
        # Finger buttons - Button class ~160x160 square, desc contains colon
        cls = node.attrib.get("class", "")
        if cls.endswith("Button") and 140 <= w <= 180 and 140 <= h <= 180 and ":" in desc:
            fingers.append(((x1 + x2) // 2, (y1 + y2) // 2))
    # Sort by y then x
    fingers.sort(key=lambda p: (p[1], p[0]))
    return fingers

def split_hands(fingers):
    """Группируем: первые 5 по y - L hand, оставшиеся 5 - R hand."""
    if len(fingers) < 10:
        return fingers, []
    # Sort by y - first half L, second half R
    return fingers[:5], fingers[5:]

# ── Шаги flow ────────────────────────────────────────────────────────────────

def go_tab(x):
    """x: 157 home, 472 history, 787 report, 1050 info"""
    tap(x, 2650, 1.5)

def open_lang_picker():
    ensure_vasolog()
    go_tab(1050)  # Info
    time.sleep(0.5)
    tap(630, 1050, 1.0)  # Settings row
    tap(630, 412, 1.5)    # Language row

def scroll_to_top_of_list():
    for _ in range(4):
        swipe(630, 400, 630, 2400, 400, 0.6)

def find_picker_item_by_name(target_name):
    """Dump UI, вернуть (cx, cy) кнопки где content-desc == target_name, или None."""
    xml = dump_ui()
    root = ET.fromstring(xml)
    for node in root.iter("node"):
        d = node.attrib.get("content-desc", "")
        cls = node.attrib.get("class", "")
        if d == target_name and "Button" in cls:
            bounds = node.attrib.get("bounds", "")
            m = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", bounds)
            if m:
                x1, y1, x2, y2 = map(int, m.groups())
                return (x1 + x2) // 2, (y1 + y2) // 2
    return None

def tap_lang_by_name(target_name):
    """Ищет пункт языка в picker по native name.
    Скроллит до N раз если не найден. Возвращает True если tap сделан."""
    scroll_to_top_of_list()
    for scroll_attempt in range(4):
        pt = find_picker_item_by_name(target_name)
        if pt is not None:
            cx, cy = pt
            # Принимаем любую видимую позицию в content area (top 170 = header, bottom nav = 2649)
            if 200 <= cy <= 2640:
                tap(cx, cy, 2.5)
                return True
        # Scroll вниз
        swipe(630, 2200, 630, 1400, 400, 0.7)
        swipe(630, 2200, 630, 1400, 400, 0.9)
    print(f"    [ERR] language '{target_name}' not found in picker")
    return False

def switch_language(code):
    name = LANG_NATIVE_NAME[code]
    print(f"  [lang] switching to {code} ('{name}')")
    open_lang_picker()
    if not tap_lang_by_name(name):
        # Fallback: закрыть picker
        back(1.0)
        raise RuntimeError(f"Cannot find language {code} ({name})")
    ensure_vasolog()
    # После выбора языка мы в Settings screen - выходим
    back(1.0)
    back(1.0)
    ensure_vasolog()
    tap(157, 2650, 1.5)

def scroll_form_to_top():
    for _ in range(6):
        swipe(630, 600, 630, 2400, 300, 0.4)

def scroll_form_to_bottom():
    for _ in range(8):
        swipe(630, 2200, 630, 600, 300, 0.4)

def tap_all_fingers_L(L_fingers):
    """Тапаем все 5 пальцев на L hand - в ref_03 выбраны ВСЕ 5."""
    for cx, cy in L_fingers:
        tap(cx, cy, 0.35)

def tap_selected_fingers_R(R_fingers):
    """На R hand в ref_03 выбраны 3 пальца: pinky, ring, thumb.
    R_fingers отсортированы по y. Состав:
      - По x возрастанию на top row: pinky, ring, middle, index (слева-направо на R hand)
      - Thumb отдельно, обычно имеет бОльший y.
    Select: pinky (самый левый top), ring (второй слева top), thumb (отдельный).
    """
    # Сначала thumb - y максимальный из 5
    r_by_y = sorted(R_fingers, key=lambda p: p[1])
    top4 = r_by_y[:4]   # top row
    thumb = r_by_y[4]   # самый нижний
    # Top row по x возрастанию: pinky, ring, middle, index
    top4_by_x = sorted(top4, key=lambda p: p[0])
    pinky = top4_by_x[0]
    ring = top4_by_x[1]
    # Тапаем: pinky, ring, thumb
    for pt in [pinky, ring, thumb]:
        tap(*pt, 0.35)

# ── Capture 6 screens ────────────────────────────────────────────────────────

def capture_lang(code):
    out_dir = OUT_DIR / code
    out_dir.mkdir(parents=True, exist_ok=True)

    ensure_vasolog()

    # 1. Home
    go_tab(157)
    time.sleep(0.3)
    screencap(out_dir / "01_home.png")
    print(f"    01 home")

    # 2. FAB → form top
    tap(630, 2530, 2.0)
    ensure_vasolog()
    screencap(out_dir / "02_add_top.png")
    print(f"    02 top")

    # Целевая позиция scroll'а: 2 свайпа (~2400px down) + 1 мини-свайп (~420px)
    # = ref_03 position (оба hand видны, без pills над "Поражённые пальцы").
    swipe(630, 2000, 630, 800, 400, 1.2)    # -1200
    swipe(630, 2000, 630, 800, 400, 1.5)    # -2400
    swipe(630, 2000, 630, 1580, 300, 1.5)   # -2820 = ref_03 position

    # Dump UI - на этой позиции видны ОБЕ hands, tree содержит 10 finger buttons
    xml = dump_ui()
    fingers = find_finger_buttons(xml)
    print(f"    found {len(fingers)} finger buttons at ref_03 position")

    by_y = sorted(fingers, key=lambda p: p[1])
    L = by_y[:5] if len(by_y) >= 5 else by_y
    R = by_y[5:10] if len(by_y) >= 10 else by_y[5:]
    print(f"    L={len(L)} R={len(R)}")

    # L hand: все 5 пальцев
    for pt in L:
        tap(*pt, 0.35)

    # R hand: 3 - pinky (leftmost top), ring (2nd), thumb (самый нижний)
    if len(R) >= 5:
        r_by_y = sorted(R, key=lambda p: p[1])
        top4 = r_by_y[:4]
        thumb = r_by_y[4]
        top4_by_x = sorted(top4, key=lambda p: p[0])
        pinky_r = top4_by_x[0]
        ring_r = top4_by_x[1]
        for pt in [pinky_r, ring_r, thumb]:
            tap(*pt, 0.35)

    # После тапов УЖЕ в ref_03 position - сразу screenshot
    time.sleep(0.5)
    screencap(out_dir / "03_add_hands.png")
    print(f"    03 hands")

    # Scroll вниз к ref_05 position (R hand + Сохранить)
    swipe(630, 2000, 630, 800, 400, 0.8)
    swipe(630, 2000, 630, 1400, 300, 1.2)
    screencap(out_dir / "05_add_bottom.png")
    print(f"    05 bottom")

    # Back (не сохраняем!)
    back(1.5)
    ensure_vasolog()

    # 4. History
    go_tab(472)
    time.sleep(0.3)
    screencap(out_dir / "04_history.png")
    print(f"    04 history")

    # 6. Report
    go_tab(787)
    time.sleep(0.3)
    screencap(out_dir / "06_report.png")
    print(f"    06 report")


def main():
    # Аргументы: список языков. По умолчанию все 18.
    args = sys.argv[1:]
    if not args:
        langs = list(LANG_PICKER_IDX.keys())
    else:
        langs = args

    print(f"=== Capturing {len(langs)} langs: {langs} ===")
    ensure_vasolog()

    for i, code in enumerate(langs, 1):
        print(f"\n[{i}/{len(langs)}] {code}")
        try:
            switch_language(code)
            capture_lang(code)
        except Exception as e:
            print(f"  [ERR] {e}")
            # Восстанавливаемся
            ensure_vasolog()

    print("\n=== DONE ===")


if __name__ == "__main__":
    main()
