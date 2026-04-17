"""
VasoLog Premium App Store Mockup Generator v4
Design: Calm/Headspace/Ada-style with Raynaud brand colors

Canvas: 1260×2798px (9:19.5 ratio)
Phone: 1100×2310px frame (titanium), 1076×2286px screen content
Screen tilt: 10° counter-clockwise

Components:
- Layered gradient background (purple/black → brand → light purple)
- Radial glow at top-center
- Noise texture 4% opacity
- Paint-blob accent (bottom-left, orange)
- Premium glass reflection
- Dimensional shadow
- Typography (headline + subhead)
- USP badge (screen 03 only)
- Medical emoji (screen 06 only)
"""

import os
from pathlib import Path
import random
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math

# Load headlines
from headlines_v2 import HEADLINES_V2, USP_BADGES

# ==================== CONFIG ====================

CANVAS_W = 1260
CANVAS_H = 2798

PHONE_FRAME_W = 1100
PHONE_FRAME_H = 2310
PHONE_FRAME_COLOR = (28, 28, 30)  # Titanium #1C1C1E
PHONE_FRAME_BORDER = 2
PHONE_OUTER_RADIUS = 68
PHONE_INSET = 12
PHONE_SCREEN_W = PHONE_FRAME_W - 2 * PHONE_INSET
PHONE_SCREEN_H = PHONE_FRAME_H - 2 * PHONE_INSET
PHONE_INNER_RADIUS = 58

# Button hints (left side)
BUTTON_WIDTH = 4
VOL_UP_Y = 400
VOL_DOWN_Y = 650
BUTTON_HEIGHT = 160

# Side power button (right)
POWER_Y = 450
POWER_HEIGHT = 200

# Gradient background
GRADIENT_TOP = (15, 8, 32)      # #0F0820
GRADIENT_MID = (94, 53, 177)    # #5E35B1
GRADIENT_BOT = (139, 92, 246)   # #8B5CF6

# Radial glow
GLOW_DIAMETER = 800
GLOW_OPACITY = 0.12

# Noise
NOISE_OPACITY = 0.04

# Paint blob (bottom-left)
BLOB_COLOR = (255, 112, 67)     # #FF7043
BLOB_OPACITY = 0.15
BLOB_RADIUS = 120
BLOB_BLUR = 80

# Glass reflection
GLASS_OPACITY_START = 0.25
GLASS_OPACITY_END = 0.0

# Shadow
SHADOW_BLUR = 60
SHADOW_COLOR = (0, 0, 0, 140)
SHADOW_OFFSET_X = 10
SHADOW_OFFSET_Y = 40

# Phone rotation (CCW = positive angle)
PHONE_ROTATION = 10

# Typography
HEADLINE_SIZE = 100
HEADLINE_COLOR = (255, 255, 255)
HEADLINE_SHADOW = (0, 0, 0, 80)
HEADLINE_SHADOW_BLUR = 6
HEADLINE_SHADOW_OFFSET = 2
HEADLINE_Y_START = 140

SUBHEAD_SIZE = 48
SUBHEAD_COLOR = (255, 255, 255, 210)
SUBHEAD_OFFSET = 40

# USP Badge (screen 03)
USP_COLOR = (255, 112, 67)      # #FF7043
USP_TEXT_SIZE = 42
USP_RADIUS = 32
USP_H_PADDING = 34
USP_V_PADDING = 14
USP_GLOW_OPACITY = 0.25
USP_GLOW_BLUR = 30
USP_OFFSET = 30

# Medical emoji (screen 06)
EMOJI_SIZE = 100
EMOJI_OPACITY = 0.2
EMOJI_PADDING = 60

# Font fallbacks
FONT_PRIMARY = "Segoe UI"
FONT_FALLBACKS = {
    "ja": "C:\\Windows\\Fonts\\YuGothB.ttc",
    "ko": "C:\\Windows\\Fonts\\malgunbd.ttf",
}

# ==================== HELPERS ====================

def get_font(size, bold=False, lang="en"):
    """Load font with fallbacks"""
    fallback_path = FONT_FALLBACKS.get(lang)

    if fallback_path and os.path.exists(fallback_path):
        try:
            return ImageFont.truetype(fallback_path, size=size)
        except:
            pass

    # Try Segoe UI
    try:
        weight = "bold" if bold else "regular"
        return ImageFont.truetype(f"C:\\Windows\\Fonts\\segoe{('ui' if not bold else 'uib')}.ttf", size=size)
    except:
        pass

    # Fallback to default
    return ImageFont.load_default()


def add_noise(img, opacity=0.04):
    """Add subtle perlin-style noise texture"""
    w, h = img.size
    noise_layer = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    pixels = noise_layer.load()

    random.seed(42)  # Deterministic
    for x in range(w):
        for y in range(h):
            grain = int(random.gauss(128, 20))
            grain = max(0, min(255, grain))
            alpha = int(255 * opacity)
            pixels[x, y] = (grain, grain, grain, alpha)

    # Slight blur for smoothness
    noise_layer = noise_layer.filter(ImageFilter.GaussianBlur(2))

    img.paste(noise_layer, (0, 0), noise_layer)
    return img


def create_gradient_background():
    """Create vertical gradient background with radial glow"""
    img = Image.new('RGB', (CANVAS_W, CANVAS_H))
    pixels = img.load()

    # Vertical gradient top → mid → bot
    for y in range(CANVAS_H):
        t = y / CANVAS_H
        if t < 0.5:
            # Top to mid
            t2 = t * 2
            r = int(GRADIENT_TOP[0] * (1 - t2) + GRADIENT_MID[0] * t2)
            g = int(GRADIENT_TOP[1] * (1 - t2) + GRADIENT_MID[1] * t2)
            b = int(GRADIENT_TOP[2] * (1 - t2) + GRADIENT_MID[2] * t2)
        else:
            # Mid to bot
            t2 = (t - 0.5) * 2
            r = int(GRADIENT_MID[0] * (1 - t2) + GRADIENT_BOT[0] * t2)
            g = int(GRADIENT_MID[1] * (1 - t2) + GRADIENT_BOT[1] * t2)
            b = int(GRADIENT_MID[2] * (1 - t2) + GRADIENT_BOT[2] * t2)

        for x in range(CANVAS_W):
            pixels[x, y] = (r, g, b)

    # Add radial glow at top-center
    glow_layer = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    glow_pixels = glow_layer.load()

    glow_x = CANVAS_W // 2
    glow_y = -GLOW_DIAMETER // 2

    for y in range(CANVAS_H):
        for x in range(CANVAS_W):
            dx = x - glow_x
            dy = y - glow_y
            dist = math.sqrt(dx*dx + dy*dy)

            if dist < GLOW_DIAMETER / 2:
                falloff = 1.0 - (dist / (GLOW_DIAMETER / 2))
                alpha = int(255 * GLOW_OPACITY * falloff * falloff)
                glow_pixels[x, y] = (255, 255, 255, alpha)

    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(40))
    img.paste(glow_layer, (0, 0), glow_layer)

    # Add noise
    img = img.convert('RGBA')
    add_noise(img, NOISE_OPACITY)
    img = img.convert('RGB')

    return img


def create_phone_frame():
    """Create phone frame (no notch, no status bar)"""
    frame = Image.new('RGBA', (PHONE_FRAME_W, PHONE_FRAME_H), PHONE_FRAME_COLOR + (255,))
    draw = ImageDraw.Draw(frame)

    # Outer rounded rectangle (frame border)
    draw.rounded_rectangle(
        [(0, 0), (PHONE_FRAME_W - 1, PHONE_FRAME_H - 1)],
        radius=PHONE_OUTER_RADIUS,
        outline=PHONE_FRAME_COLOR,
        width=PHONE_FRAME_BORDER
    )

    # Side buttons - left (volume)
    btn_x = -BUTTON_WIDTH // 2
    draw.rectangle([(btn_x, VOL_UP_Y), (btn_x + BUTTON_WIDTH, VOL_UP_Y + BUTTON_HEIGHT)],
                  fill=(80, 80, 80))
    draw.rectangle([(btn_x, VOL_DOWN_Y), (btn_x + BUTTON_WIDTH, VOL_DOWN_Y + BUTTON_HEIGHT)],
                  fill=(80, 80, 80))

    # Side buttons - right (power)
    btn_x = PHONE_FRAME_W - BUTTON_WIDTH // 2
    draw.rectangle([(btn_x, POWER_Y), (btn_x + BUTTON_WIDTH, POWER_Y + POWER_HEIGHT)],
                  fill=(80, 80, 80))

    return frame


def create_screen_from_raw(raw_path):
    """Load and process raw screenshot"""
    if not os.path.exists(raw_path):
        raise FileNotFoundError(f"Raw screenshot not found: {raw_path}")

    # Load raw
    raw = Image.open(raw_path).convert('RGBA')

    # Crop status bar (100px) + nav bar (195px) = 295px
    raw_w, raw_h = raw.size
    top_crop = 100
    bot_crop = 195

    cropped = raw.crop((0, top_crop, raw_w, raw_h - bot_crop))

    # Scale to fit phone screen
    cropped.thumbnail((PHONE_SCREEN_W, PHONE_SCREEN_H), Image.Resampling.LANCZOS)

    # Paste on transparent with rounded corners
    screen = Image.new('RGBA', (PHONE_SCREEN_W, PHONE_SCREEN_H), (0, 0, 0, 0))

    # Create mask for rounded corners
    mask = Image.new('L', (PHONE_SCREEN_W, PHONE_SCREEN_H), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (PHONE_SCREEN_W - 1, PHONE_SCREEN_H - 1)],
                                radius=PHONE_INNER_RADIUS, fill=255)

    # Center cropped on screen
    offset_x = (PHONE_SCREEN_W - cropped.width) // 2
    offset_y = (PHONE_SCREEN_H - cropped.height) // 2
    screen.paste(cropped, (offset_x, offset_y), cropped)

    # Apply mask
    screen.putalpha(mask)

    return screen


def add_glass_reflection(screen_img):
    """Add glass reflection gradient overlay"""
    w, h = screen_img.size
    reflection = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    pixels = reflection.load()

    # Linear gradient white from top-left diagonal
    for y in range(h):
        for x in range(w):
            # Diagonal distance from top-left
            diag_progress = (x + y) / (w + h)

            # Fade: 25% opacity at start, 0% at end
            opacity = int(255 * GLASS_OPACITY_START * (1.0 - diag_progress))
            pixels[x, y] = (255, 255, 255, opacity)

    reflection = reflection.filter(ImageFilter.GaussianBlur(15))

    screen_img.paste(reflection, (0, 0), reflection)
    return screen_img


def add_phone_shadow(img):
    """Add dimensional shadow to phone"""
    # Create shadow layer
    shadow = Image.new('RGBA', (img.width + 100, img.height + 100), (0, 0, 0, 0))

    # Draw solid shadow shape
    shadow_draw = ImageDraw.Draw(shadow)
    x_offset = 50
    y_offset = 50

    shadow_draw.rounded_rectangle(
        [(x_offset + SHADOW_OFFSET_X, y_offset + SHADOW_OFFSET_Y),
         (x_offset + PHONE_FRAME_W + SHADOW_OFFSET_X, y_offset + PHONE_FRAME_H + SHADOW_OFFSET_Y)],
        radius=PHONE_OUTER_RADIUS,
        fill=SHADOW_COLOR
    )

    # Blur
    shadow = shadow.filter(ImageFilter.GaussianBlur(SHADOW_BLUR))

    # Composite
    result = Image.new('RGBA', (img.width + 100, img.height + 100), (0, 0, 0, 0))
    result.paste(shadow, (0, 0), shadow)
    result.paste(img, (x_offset, y_offset), img)

    return result


def draw_text_with_shadow(draw, xy, text, font, fill, shadow_color, shadow_blur_size=6, shadow_offset=2):
    """Draw text with shadow effect"""
    x, y = xy

    # Create shadow
    shadow_img = Image.new('RGBA', (2000, 400), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.text((shadow_offset, shadow_offset), text, font=font, fill=shadow_color)
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(shadow_blur_size))

    # Paste shadow to main
    draw._image.paste(shadow_img, (x - 1000, y - 100), shadow_img)

    # Draw text on top
    draw.text(xy, text, font=font, fill=fill)


def add_usp_badge(img, text, lang="en"):
    """Add USP badge for screen 03"""
    draw = ImageDraw.Draw(img)

    # Get text size
    font = get_font(USP_TEXT_SIZE, bold=True, lang=lang)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    # Badge dimensions
    badge_w = text_w + 2 * USP_H_PADDING
    badge_h = text_h + 2 * USP_V_PADDING

    # Position: center X, below subhead
    badge_x = (CANVAS_W - badge_w) // 2
    badge_y = HEADLINE_Y_START + 280

    # Glow layer
    glow = Image.new('RGBA', img.size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)

    glow_color = (255, 112, 67, int(255 * USP_GLOW_OPACITY))
    glow_draw.ellipse(
        [(badge_x - 60, badge_y - 60), (badge_x + badge_w + 60, badge_y + badge_h + 60)],
        fill=glow_color
    )
    glow = glow.filter(ImageFilter.GaussianBlur(USP_GLOW_BLUR))
    img.paste(glow, (0, 0), glow)

    # Badge background
    draw.rounded_rectangle(
        [(badge_x, badge_y), (badge_x + badge_w, badge_y + badge_h)],
        radius=USP_RADIUS,
        fill=USP_COLOR
    )

    # Badge text with sparkle
    sparkle = "✨ "
    draw.text(
        (badge_x + USP_H_PADDING, badge_y + USP_V_PADDING),
        sparkle + text,
        font=font,
        fill=(255, 255, 255)
    )


def add_medical_emoji(img):
    """Add stethoscope emoji for screen 06"""
    # For now, use text-based emoji
    draw = ImageDraw.Draw(img)
    emoji_font = get_font(EMOJI_SIZE, lang="en")

    x = CANVAS_W - EMOJI_PADDING - EMOJI_SIZE
    y = EMOJI_PADDING

    # Add emoji with opacity
    emoji_layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    emoji_draw = ImageDraw.Draw(emoji_layer)
    emoji_draw.text((x, y), "🩺", font=emoji_font, fill=(255, 255, 255, int(255 * EMOJI_OPACITY)))

    img.paste(emoji_layer, (0, 0), emoji_layer)


def make_mockup(raw_path, lang, screen_id, output_dir):
    """Generate single mockup"""

    print(f"Processing {screen_id} ({lang})...", end=" ")

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    # Get headlines
    if lang not in HEADLINES_V2 or screen_id not in HEADLINES_V2[lang]:
        print(f"SKIP (no headline)")
        return None

    headline, subhead = HEADLINES_V2[lang][screen_id]

    # Create base canvas
    canvas = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))

    # Background with gradient + glow + noise
    bg = create_gradient_background()
    bg = bg.convert('RGBA')
    canvas.paste(bg, (0, 0), bg)

    # Paint blob (bottom-left)
    blob = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    blob_draw = ImageDraw.Draw(blob)
    blob_color = BLOB_COLOR + (int(255 * BLOB_OPACITY),)
    blob_draw.ellipse(
        [(50, CANVAS_H - BLOB_RADIUS * 2 - 50),
         (50 + BLOB_RADIUS * 2, CANVAS_H - 50)],
        fill=blob_color
    )
    blob = blob.filter(ImageFilter.GaussianBlur(BLOB_BLUR))
    canvas.paste(blob, (0, 0), blob)

    # Create phone
    phone_frame = create_phone_frame()
    screen = create_screen_from_raw(raw_path)
    screen = add_glass_reflection(screen)

    # Composite screen on frame
    phone = phone_frame.copy()
    phone.paste(screen, (PHONE_INSET, PHONE_INSET), screen)

    # Add shadow
    phone_with_shadow = add_phone_shadow(phone)

    # Rotate phone 10° CCW
    phone_rotated = phone_with_shadow.rotate(PHONE_ROTATION, resample=Image.BICUBIC, expand=True)

    # Center rotated phone on canvas
    phone_x = (CANVAS_W - phone_rotated.width) // 2
    phone_y = (CANVAS_H - phone_rotated.height) // 2

    # Paste phone on canvas
    canvas.paste(phone_rotated, (phone_x, phone_y), phone_rotated)

    # Draw typography
    draw = ImageDraw.Draw(canvas)

    # Headline
    headline_font = get_font(HEADLINE_SIZE, bold=True, lang=lang)
    headline_color_rgba = HEADLINE_COLOR + (255,)

    bbox = draw.textbbox((0, 0), headline, font=headline_font)
    headline_w = bbox[2] - bbox[0]
    headline_x = (CANVAS_W - headline_w) // 2

    # Shadow
    shadow_img = Image.new('RGBA', (CANVAS_W, 300), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.text((headline_x, HEADLINE_Y_START - (CANVAS_W - headline_w) // 2),
                    headline, font=headline_font, fill=HEADLINE_SHADOW)
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(HEADLINE_SHADOW_BLUR))
    canvas.paste(shadow_img, (0, HEADLINE_Y_START - 150), shadow_img)

    # Headline text
    draw.text((headline_x, HEADLINE_Y_START), headline, font=headline_font, fill=headline_color_rgba)

    # Subhead
    subhead_font = get_font(SUBHEAD_SIZE, bold=False, lang=lang)
    subhead_color_rgba = SUBHEAD_COLOR + (255,) if len(SUBHEAD_COLOR) == 3 else SUBHEAD_COLOR

    bbox = draw.textbbox((0, 0), subhead, font=subhead_font)
    subhead_w = bbox[2] - bbox[0]
    subhead_x = (CANVAS_W - subhead_w) // 2
    subhead_y = HEADLINE_Y_START + HEADLINE_SIZE + SUBHEAD_OFFSET

    draw.text((subhead_x, subhead_y), subhead, font=subhead_font, fill=subhead_color_rgba)

    # USP badge (screen 03 only)
    if screen_id == "03_add_hands":
        usp_text = USP_BADGES.get(lang, "UNIQUE")
        add_usp_badge(canvas, usp_text, lang=lang)

    # Medical emoji (screen 06 only)
    if screen_id == "06_report":
        add_medical_emoji(canvas)

    # Save
    output_path = os.path.join(output_dir, f"{screen_id}.png")
    canvas = canvas.convert('RGB')
    canvas.save(output_path, 'PNG', quality=95)

    file_size = os.path.getsize(output_path)
    print(f"✓ {file_size / 1024:.1f}KB")

    return output_path


def main():
    """Generate all mockups"""

    base_raw = "D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw"
    base_out = "D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/mockups_v4"

    screens = ["01_home", "02_add_top", "03_add_hands", "04_history", "05_add_bottom", "06_report"]
    langs = ["en"]

    all_files = []

    for lang in langs:
        lang_dir = os.path.join(base_raw, lang)
        out_dir = os.path.join(base_out, lang)

        print(f"\n=== {lang.upper()} ===")

        for screen in screens:
            raw_file = os.path.join(lang_dir, f"{screen}.png")

            try:
                result = make_mockup(raw_file, lang, screen, out_dir)
                if result:
                    all_files.append(result)
            except Exception as e:
                print(f"ERROR {screen}: {e}")

    print(f"\n=== SUMMARY ===")
    print(f"Generated {len(all_files)} mockups")
    for f in all_files:
        size_kb = os.path.getsize(f) / 1024
        print(f"  {os.path.basename(os.path.dirname(f))}/{os.path.basename(f)} - {size_kb:.1f}KB")


if __name__ == "__main__":
    main()
