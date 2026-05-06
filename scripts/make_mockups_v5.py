"""
VasoLog Mockup Generator v5 (May 2026)
Базируется на v4, но:
- Использует headlines_v3 (native speaker fixes + strategic positioning + RCS credibility)
- Генерирует все 18 языков
- Output: mockups_v5_googleplay (1260x2798, перед обрезкой в 9:16)
- Финский 06_report берёт raw из en (Flutter UI bug в финском raw)
"""

import os
import sys
from pathlib import Path

# Добавляем scripts dir в path для импорта v4
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Подменяем headlines_v2 на v3 ДО импорта make_mockups_v4
import headlines_v3
sys.modules['headlines_v2'] = headlines_v3

# Теперь импортируем рабочий код v4
from make_mockups_v4 import make_mockup


def main():
    """Generate mockups для всех 18 языков"""

    base_raw = "D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw"
    base_out = "D:/DEV/vasolog/release/v1.1.3/store_assets/google_play/mockups_v5"

    screens = ["01_home", "02_add_top", "03_add_hands", "04_history", "05_add_bottom", "06_report"]

    # Все 18 языков из metadata
    langs = ["en", "ru", "de", "fr", "es", "pt", "it", "sv", "fi",
             "nb", "da", "nl", "pl", "cs", "hu", "uk", "ja", "ko"]

    all_files = []
    errors = []

    for lang in langs:
        lang_dir = os.path.join(base_raw, lang)
        out_dir = os.path.join(base_out, lang)

        print(f"\n=== {lang.upper()} ===")

        for screen in screens:
            raw_file = os.path.join(lang_dir, f"{screen}.png")

            # Финский 06_report имеет Flutter overflow bug в raw screenshot.
            # Используем raw из en (UI компонент тот же, текст в overlay уже финский).
            if lang == "fi" and screen == "06_report":
                raw_file = os.path.join(base_raw, "en", f"{screen}.png")
                print(f"  [fi/06_report] using en raw (Flutter overflow workaround)")

            if not os.path.exists(raw_file):
                msg = f"MISSING raw: {raw_file}"
                print(f"  ERROR: {msg}")
                errors.append(msg)
                continue

            try:
                result = make_mockup(raw_file, lang, screen, out_dir)
                if result:
                    all_files.append(result)
            except Exception as e:
                msg = f"{lang}/{screen}: {e}"
                print(f"  ERROR: {msg}")
                errors.append(msg)

    print(f"\n=== SUMMARY ===")
    print(f"Generated: {len(all_files)} mockups")
    print(f"Errors:    {len(errors)}")
    if errors:
        print("\nErrors detail:")
        for e in errors:
            print(f"  - {e}")


if __name__ == "__main__":
    main()
