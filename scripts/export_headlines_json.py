"""Экспорт HEADLINES_V2 и USP_BADGES в JSON для JS генератора."""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from headlines_v2 import HEADLINES_V2, USP_BADGES

out = {
    "headlines": {
        lang: {
            screen: {"headline": h, "subhead": s}
            for screen, (h, s) in screens.items()
        }
        for lang, screens in HEADLINES_V2.items()
    },
    "usp_badges": USP_BADGES,
}

out_path = Path(__file__).parent / "headlines_v2.json"
out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"OK: {out_path} ({len(out['headlines'])} langs)")
