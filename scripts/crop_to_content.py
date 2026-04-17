#!/usr/bin/env py
"""Crop raw ADB screenshots (1260x2844) to content area (1260x2549) - как у Alex'а.
Удаляет top status bar (100px) + bottom nav bar (195px).
"""
from PIL import Image
from pathlib import Path

RAW = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw")
CROPPED = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/cropped")

STATUS_H = 100
NAV_H = 195  # native 2844 - content 2549 = 295. Но если status=100, nav=195.

def crop_one(src: Path, dst: Path):
    img = Image.open(src)
    w, h = img.size
    if (w, h) != (1260, 2844):
        print(f"  [WARN] unexpected size {w}x{h}, using fractional crop")
        top = int(h * STATUS_H / 2844)
        bot = int(h - h * NAV_H / 2844)
    else:
        top = STATUS_H
        bot = h - NAV_H
    out = img.crop((0, top, w, bot))
    dst.parent.mkdir(parents=True, exist_ok=True)
    out.save(dst, "PNG", optimize=True)


def main():
    langs = sorted([d.name for d in RAW.iterdir() if d.is_dir()])
    total = 0
    for lang in langs:
        for src in (RAW / lang).glob("*.png"):
            dst = CROPPED / lang / src.name
            crop_one(src, dst)
            total += 1
        print(f"  {lang}: done")
    print(f"Total cropped: {total}")


if __name__ == "__main__":
    main()
