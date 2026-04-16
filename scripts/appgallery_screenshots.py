#!/usr/bin/env python3
"""
VasoLog AppGallery Screenshot Automation
Снимает скриншоты всех ключевых экранов на 18 языках через ADB.

Требование: телефон подключён, приложение открыто на экране выбора языка.
Запуск: python scripts/appgallery_screenshots.py
"""
import subprocess
import time
import os
import sys
from pathlib import Path

ADB = "/d/dev/AndroidSDK/platform-tools/adb.exe"

# Разрешение экрана устройства
W, H = 1260, 2844

# Координаты нижнего nav bar (y определена по предыдущим экспериментам)
NAV_Y = 2650
NAV_HOME    = (157,  NAV_Y)
NAV_HISTORY = (472,  NAV_Y)
NAV_REPORT  = (787,  NAV_Y)
NAV_INFO    = (1050, NAV_Y)

# FAB кнопка (+)
FAB = (630, 2530)

# Координаты в экране выбора языка
# Калибровка: тап y=419 → выбрался "Системный" (пункт 0)
# Шаг: 13 видимых пунктов в display 886x2000, spacing ~137px display → ~194px actual
LANG_LIST_X = 630
LANG_ITEM_0_Y = 419   # Системный (откалибровано)
LANG_STEP_Y   = 194   # шаг между пунктами (actual px)

# Все 18 языков + индекс в списке (0=Системный, 1=English, ...)
LANGUAGES = [
    ("en", "English",      1),
    ("ru", "ru",           2),
    ("de", "de",           3),
    ("fr", "fr",           4),
    ("es", "es",           5),
    ("pt", "pt",           6),
    ("it", "it",           7),
    ("sv", "sv",           8),
    ("fi", "fi",           9),
    ("nb", "nb",          10),
    ("da", "da",          11),
    ("nl", "nl",          12),
    ("pl", "pl",          13),
    ("cs", "cs",          14),
    ("hu", "hu",          15),
    ("uk", "uk",          16),
    ("ja", "ja",          17),
    ("ko", "ko",          18),
]

OUT_DIR = Path("/d/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw")


# ── ADB helpers ─────────────────────────────────────────────────────────────

def adb(*args):
    result = subprocess.run([ADB] + list(args), capture_output=True, text=True)
    return result.stdout.strip()

def tap(x, y, delay=1.5):
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(delay)

def swipe_up(px=600):
    """Прокрутить список вверх (свайп вверх = скролл вниз)"""
    adb("shell", "input", "swipe", "630", "1800", "630", str(1800 - px), "300")
    time.sleep(0.8)

def swipe_down_full():
    """Вернуться в начало списка"""
    adb("shell", "input", "swipe", "630", "400", "630", "2400", "500")
    time.sleep(1)

def back(delay=1.2):
    adb("shell", "input", "keyevent", "4")
    time.sleep(delay)

def screenshot(path: Path):
    result = subprocess.run([ADB, "exec-out", "screencap", "-p"], capture_output=True)
    if result.stdout and len(result.stdout) > 1000:
        with open(path, "wb") as f:
            f.write(result.stdout)
        return True
    print(f"  WARN: скриншот пустой: {path.name}")
    return False


# ── Навигация ────────────────────────────────────────────────────────────────

def go_home():
    """Перейти на главный экран через nav bar"""
    tap(*NAV_HOME)

def go_history():
    tap(*NAV_HISTORY)

def go_report():
    tap(*NAV_REPORT)

def go_info():
    tap(*NAV_INFO)

def open_fab():
    """Открыть экран добавления приступа через FAB (+)"""
    tap(*FAB, delay=2)

def close_fab():
    """Закрыть экран добавления (кнопка назад)"""
    back()

def open_language_picker():
    """
    Из любого места в приложении: Info → Settings → Language picker
    """
    go_info()
    time.sleep(1)
    # Tap Settings row (y ≈ 1050 по прошлому эксперименту)
    tap(630, 1050, delay=1.5)
    # Tap Language row
    tap(630, 412, delay=2)


def select_language(lang_index: int):
    """
    Выбрать язык по индексу в списке.
    lang_index: 0=Системный, 1=English, 2=Русский, ...
    Предполагается что список уже открыт и прокручен в начало.
    """
    # Сначала прокрутить в начало
    swipe_down_full()
    time.sleep(0.5)

    target_y = LANG_ITEM_0_Y + lang_index * LANG_STEP_Y

    if target_y > H - 300:
        # Нужна прокрутка: считаем сколько прокручивать
        scroll_needed = target_y - (H - 400)
        swipe_up(scroll_needed)
        time.sleep(0.5)
        # После прокрутки пересчитываем y
        target_y = LANG_ITEM_0_Y + lang_index * LANG_STEP_Y - scroll_needed

    tap(LANG_LIST_X, target_y, delay=2.5)


# ── Основной цикл ─────────────────────────────────────────────────────────

def take_screenshots_for_lang(lang_code: str, out_dir: Path):
    """Снять 4 скриншота ключевых экранов для текущего языка."""
    out_dir.mkdir(parents=True, exist_ok=True)

    # 1. Главный экран
    go_home()
    time.sleep(1)
    screenshot(out_dir / "01_home.png")
    print(f"    [1/4] home OK")

    # 2. Экран добавления приступа (FAB)
    open_fab()
    screenshot(out_dir / "02_add_episode.png")
    print(f"    [2/4] add_episode OK")
    close_fab()
    time.sleep(1)

    # 3. История
    go_history()
    time.sleep(1)
    screenshot(out_dir / "03_history.png")
    print(f"    [3/4] history OK")

    # 4. Отчёт / статистика
    go_report()
    time.sleep(1)
    screenshot(out_dir / "04_report.png")
    print(f"    [4/4] report OK")


def main():
    print("=== VasoLog AppGallery Screenshots ===")
    print(f"Вывод: {OUT_DIR}")
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # Проверить подключение устройства
    devices = adb("devices")
    if "device" not in devices:
        print("ОШИБКА: устройство не подключено!")
        sys.exit(1)
    print(f"Устройство: OK\n")

    # Открыть список языков (с текущего места)
    print("Открываю список языков...")
    open_language_picker()
    time.sleep(1)

    total = len(LANGUAGES)
    for i, (lang_code, _label, lang_index) in enumerate(LANGUAGES):
        print(f"\n[{i+1}/{total}] Язык: {lang_code} (индекс {lang_index})")

        # Выбрать язык
        select_language(lang_index)
        print(f"  Язык применён, жду перестройку...")
        time.sleep(2.5)

        # Снять скриншоты
        lang_dir = OUT_DIR / lang_code
        take_screenshots_for_lang(lang_code, lang_dir)

        # Вернуться к списку языков для следующей итерации
        if i < total - 1:
            print("  Возвращаюсь к списку языков...")
            open_language_picker()
            time.sleep(1)

    print(f"\n=== ГОТОВО: {total} языков × 4 экрана ===")
    print(f"Скриншоты в: {OUT_DIR}")


if __name__ == "__main__":
    main()
