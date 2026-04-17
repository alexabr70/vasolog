"""
Premium App Store Mockup Generator v3
Generates Apple/Headspace/Calm 2026 quality mockups for vasolog

Requirements:
- PIL/Pillow >= 10.0.0
- numpy >= 1.24.0
- scipy >= 1.10.0 (optional, for advanced noise)

Dimensions: 1260×2798px (9:19.5 native ratio, no scaling)
"""

import math
from pathlib import Path
from typing import Optional, Tuple

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


# ============================================================================
# Configuration
# ============================================================================

CANVAS_W, CANVAS_H = 1260, 2798
SCREEN_W, SCREEN_H = 1100, 2245  # Inner screen area
PHONE_PADDING = 80  # Left/right padding for phone frame

RAW_ROOT = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw")
OUT_ROOT = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/mockups_v3")

# Colors
COLOR_BG_TOP = (26, 15, 58)  # #1A0F3A deep purple/black
COLOR_BG_MID = (94, 53, 177)  # #5E35B1 brand purple
COLOR_BG_BTM = (124, 58, 237)  # #7C3AED lighter at bottom
COLOR_FRAME = (58, 58, 60)  # #3A3A3C titanium dark (phone frame)
COLOR_ISLAND = (0, 0, 0)  # #000 dynamic island
COLOR_SHADOW = (0, 0, 0, 100)  # Shadow color with alpha
COLOR_TEXT_HEADLINE = (255, 255, 255)  # #FFFFFF white
COLOR_TEXT_SUBHEAD = (255, 255, 255, 230)  # Slightly transparent

# USP Badge colors
COLOR_BADGE_BG = (255, 112, 67)  # #FF7043 orange
COLOR_BADGE_TEXT = (255, 255, 255)  # White text

# Typography
FONT_SIZE_HEADLINE = 100
FONT_SIZE_SUBHEAD = 48
FONT_SIZE_BADGE = 42
LINE_HEIGHT_HEADLINE = 1.12
LINE_HEIGHT_SUBHEAD = 1.25

# Measurements
HEADLINE_TOP_Y = 130
SUBHEAD_BELOW_HEADLINE = 30
BADGE_BELOW_SUBHEAD = 25
PHONE_TOP_Y = 750  # Approximate, will adjust based on content

# Phone frame
FRAME_STROKE = 3
FRAME_OUTER_RADIUS = 72
FRAME_INNER_RADIUS = 64

# Dynamic Island
ISLAND_WIDTH = 360
ISLAND_HEIGHT = 115
ISLAND_RADIUS = 57  # Half of height
ISLAND_TOP_OFFSET = 42

# Glass reflection
GLASS_OPACITY = 40

# Shadow
SHADOW_BLUR = 40
SHADOW_Y_OFFSET = 30
SHADOW_SPREAD = 60

# Font files (with fallback)
FONT_PATHS = {
    "headline": [
        "C:/Windows/Fonts/segoeuib.ttf",  # Segoe UI Bold
        "C:/Windows/Fonts/arialbd.ttf",
    ],
    "subhead": [
        "C:/Windows/Fonts/segoeui.ttf",  # Segoe UI Regular
        "C:/Windows/Fonts/arial.ttf",
    ],
    "badge": [
        "C:/Windows/Fonts/segoeuib.ttf",
        "C:/Windows/Fonts/arialbd.ttf",
    ],
    "cjk_ja": [
        "C:/Windows/Fonts/YuGothB.ttc",
    ],
    "cjk_ko": [
        "C:/Windows/Fonts/malgunbd.ttf",
    ],
}

HEADLINES = {
    "en": {
        "01_home": (
            "Your Raynaud's,\ndecoded.",
            "Weather, attacks, triggers — one place",
        ),
        "02_add_top": (
            "Log an attack in\n10 seconds",
            "Severity, color, fingers — at a glance",
        ),
        "03_add_hands": (
            "Every finger\ntells a story",
            "Tap exactly where — only here",
        ),
        "04_history": (
            "Patterns your\ndoctor misses",
            "Weekly charts reveal YOUR triggers",
        ),
        "05_add_bottom": (
            "Never forget\nan attack",
            "Photos, notes, full history",
        ),
        "06_report": (
            "Your doctor\nwill thank you",
            "6-month medical PDF — one tap",
        ),
    },
}

# USP badges (only for 03_add_hands)
USP_BADGES = {
    "en": "UNIQUE",
}


# ============================================================================
# Utility Functions
# ============================================================================


def load_font(font_type: str, size: int, lang: str = "en") -> ImageFont.FreeTypeFont:
    """Load font with fallback chain."""
    paths = FONT_PATHS.get(font_type, [])

    # Add CJK fonts if needed
    if lang == "ja" and "cjk_ja" in FONT_PATHS:
        paths = FONT_PATHS["cjk_ja"] + paths
    elif lang == "ko" and "cjk_ko" in FONT_PATHS:
        paths = FONT_PATHS["cjk_ko"] + paths

    for path in paths:
        try:
            return ImageFont.truetype(path, size=size)
        except (OSError, IOError):
            continue

    # Fallback to default
    print(f"⚠ Font not found for {font_type}/{lang}, using default")
    return ImageFont.load_default()


def hex_to_rgb(hex_color: str) -> Tuple[int, int, int]:
    """Convert #RRGGBB to (R, G, B)."""
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def create_gradient_canvas(
    width: int, height: int, color_top: Tuple, color_mid: Tuple, color_btm: Tuple
) -> Image.Image:
    """Create vertical gradient background with subtle radial glow."""
    # Create base gradient (top → bottom)
    gradient = Image.new("RGB", (width, height))
    pixels = gradient.load()

    for y in range(height):
        # Linear interpolation through 3 colors
        if y < height // 2:
            # Top half: color_top → color_mid
            ratio = y / (height // 2)
            r = int(color_top[0] * (1 - ratio) + color_mid[0] * ratio)
            g = int(color_top[1] * (1 - ratio) + color_mid[1] * ratio)
            b = int(color_top[2] * (1 - ratio) + color_mid[2] * ratio)
        else:
            # Bottom half: color_mid → color_btm
            ratio = (y - height // 2) / (height - height // 2)
            r = int(color_mid[0] * (1 - ratio) + color_btm[0] * ratio)
            g = int(color_mid[1] * (1 - ratio) + color_btm[1] * ratio)
            b = int(color_mid[2] * (1 - ratio) + color_btm[2] * ratio)

        for x in range(width):
            pixels[x, y] = (r, g, b)

    # Add subtle radial glow at top center (white 8% opacity)
    glow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_center_x = width // 2
    glow_center_y = -100  # Above canvas
    glow_radius = 800

    # Draw radial glow with many circles of decreasing opacity
    for i in range(glow_radius, 0, -20):
        alpha = int(20 * (1 - i / glow_radius) * 0.08)  # 8% max opacity
        glow_draw.ellipse(
            [
                glow_center_x - i,
                glow_center_y - i,
                glow_center_x + i,
                glow_center_y + i,
            ],
            fill=(255, 255, 255, alpha),
        )

    glow = glow.filter(ImageFilter.GaussianBlur(radius=100))
    gradient.paste(Image.new("RGB", glow.size, color_top), (0, 0), glow)

    return gradient


def add_noise_texture(image: Image.Image, opacity: float = 0.04) -> Image.Image:
    """Add noise texture overlay for premium feel."""
    width, height = image.size

    # Create noise using numpy
    noise = np.random.randint(0, 256, (height, width, 3), dtype=np.uint8)

    # Gaussian blur for subtle effect
    noise_img = Image.fromarray(noise)
    noise_img = noise_img.filter(ImageFilter.GaussianBlur(radius=2))

    # Convert to RGBA and adjust opacity
    noise_rgba = Image.new("RGBA", noise_img.size)
    noise_rgba.paste(noise_img)

    # Blend noise onto original
    noise_array = np.array(noise_rgba, dtype=np.float32)
    noise_array[:, :, 3] = noise_array[:, :, 3] * opacity
    noise_img_transparent = Image.fromarray(np.uint8(noise_array))

    # Convert image to RGBA for compositing
    if image.mode != "RGBA":
        image_rgba = image.convert("RGBA")
    else:
        image_rgba = image.copy()

    result = Image.alpha_composite(image_rgba, noise_img_transparent)
    return result.convert("RGB") if image.mode == "RGB" else result


def draw_rounded_rect(
    draw: ImageDraw.ImageDraw,
    bbox: Tuple[int, int, int, int],
    radius: int,
    fill: Optional[Tuple] = None,
    outline: Optional[Tuple] = None,
    width: int = 1,
) -> None:
    """Draw rounded rectangle."""
    x0, y0, x1, y1 = bbox

    # Draw four rounded corners
    draw.arc([x0, y0, x0 + radius * 2, y0 + radius * 2], 180, 270, fill=outline, width=width)
    draw.arc([x1 - radius * 2, y0, x1, y0 + radius * 2], 270, 360, fill=outline, width=width)
    draw.arc([x1 - radius * 2, y1 - radius * 2, x1, y1], 0, 90, fill=outline, width=width)
    draw.arc([x0, y1 - radius * 2, x0 + radius * 2, y1], 90, 180, fill=outline, width=width)

    # Draw edges
    draw.line([x0 + radius, y0, x1 - radius, y0], fill=outline, width=width)
    draw.line([x0 + radius, y1, x1 - radius, y1], fill=outline, width=width)
    draw.line([x0, y0 + radius, x0, y1 - radius], fill=outline, width=width)
    draw.line([x1, y0 + radius, x1, y1 - radius], fill=outline, width=width)

    # Fill interior
    if fill:
        draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
        draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
        draw.polygon(
            [
                x0 + radius,
                y0,
                x1 - radius,
                y0,
                x1,
                y0 + radius,
                x1,
                y1 - radius,
                x1 - radius,
                y1,
                x0 + radius,
                y1,
                x0,
                y1 - radius,
                x0,
                y0 + radius,
            ],
            fill=fill,
        )


def draw_phone_frame(
    canvas: Image.Image, screen_img: Image.Image, phone_x: int, phone_y: int
) -> Tuple[int, int, int, int]:
    """
    Draw iPhone 16 Pro frame with dynamic island.

    Returns: (screen_rect_x0, screen_rect_y0, screen_rect_x1, screen_rect_y1)
    """
    draw = ImageDraw.Draw(canvas)

    # Phone frame outer dimensions
    phone_w = SCREEN_W + PHONE_PADDING * 2  # But we'll use calculated positions
    phone_h = SCREEN_H + 300  # Extra for frame beyond screen

    # Outer frame bounding box
    frame_x0 = phone_x - PHONE_PADDING
    frame_y0 = phone_y
    frame_x1 = phone_x + SCREEN_W + PHONE_PADDING
    frame_y1 = phone_y + SCREEN_H + 100

    # Draw frame with stroke and rounded corners
    # Outer stroke (titanium dark)
    for i in range(FRAME_STROKE):
        draw.rounded_rectangle(
            [frame_x0 - i, frame_y0 - i, frame_x1 + i, frame_y1 + i],
            radius=FRAME_OUTER_RADIUS + i,
            outline=COLOR_FRAME,
            width=1,
        )

    # Screen area with rounded corners
    screen_rect = (phone_x, phone_y, phone_x + SCREEN_W, phone_y + SCREEN_H)

    # Black bezel/background
    draw.rounded_rectangle(
        [phone_x - 10, phone_y - 10, phone_x + SCREEN_W + 10, phone_y + SCREEN_H + 10],
        radius=FRAME_INNER_RADIUS,
        fill=(0, 0, 0),
    )

    # Paste screen content with rounded corners
    if screen_img.size != (SCREEN_W, SCREEN_H):
        screen_img = screen_img.resize((SCREEN_W, SCREEN_H), Image.Resampling.LANCZOS)

    # Create mask for rounded corners
    mask = Image.new("L", (SCREEN_W, SCREEN_H), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [0, 0, SCREEN_W, SCREEN_H], radius=FRAME_INNER_RADIUS, fill=255
    )

    screen_img.putalpha(mask)
    canvas.paste(screen_img, (phone_x, phone_y), screen_img)

    # Dynamic Island (pill-shaped at top)
    island_x0 = phone_x + (SCREEN_W - ISLAND_WIDTH) // 2
    island_y0 = phone_y + ISLAND_TOP_OFFSET
    island_x1 = island_x0 + ISLAND_WIDTH
    island_y1 = island_y0 + ISLAND_HEIGHT

    # Draw filled pill shape
    draw.rounded_rectangle(
        [island_x0, island_y0, island_x1, island_y1],
        radius=ISLAND_RADIUS,
        fill=COLOR_ISLAND,
    )

    # Side buttons (optional, for realism)
    button_color = (100, 100, 100)  # Gray

    # Left buttons (volume)
    vol_up_y = phone_y + 300
    vol_down_y = phone_y + 500

    draw.rectangle(
        [frame_x0 - 6, vol_up_y, frame_x0 - 2, vol_up_y + 200],
        fill=button_color,
    )
    draw.rectangle(
        [frame_x0 - 6, vol_down_y, frame_x0 - 2, vol_down_y + 200],
        fill=button_color,
    )

    # Right button (power/side)
    power_y = phone_y + 600
    draw.rectangle(
        [frame_x1 + 2, power_y, frame_x1 + 6, power_y + 240],
        fill=button_color,
    )

    return screen_rect


def add_glass_reflection(canvas: Image.Image, screen_rect: Tuple[int, int, int, int]) -> None:
    """Add glass reflection overlay to screen."""
    x0, y0, x1, y1 = screen_rect

    # Create reflection gradient (top-left to center)
    reflection = Image.new("RGBA", (x1 - x0, y1 - y0), (0, 0, 0, 0))
    reflection_array = np.array(reflection, dtype=np.float32)

    width = x1 - x0
    height = y1 - y0

    for y in range(height):
        for x in range(width):
            # Distance from top-left corner
            dist = math.sqrt(x**2 + y**2)
            max_dist = math.sqrt(width**2 + height**2)

            # Opacity decreases with distance
            opacity = max(0, 1 - (dist / max_dist)) * (GLASS_OPACITY / 100)
            reflection_array[y, x, 3] = opacity * 255
            reflection_array[y, x, :3] = [255, 255, 255]

    reflection = Image.fromarray(np.uint8(reflection_array))
    reflection = reflection.filter(ImageFilter.GaussianBlur(radius=40))

    # Composite onto canvas
    if canvas.mode != "RGBA":
        canvas_rgba = canvas.convert("RGBA")
    else:
        canvas_rgba = canvas.copy()

    canvas_rgba.paste(reflection, (x0, y0), reflection)

    # Copy back
    canvas_data = canvas.load()
    canvas_rgba_data = canvas_rgba.load()
    for y in range(canvas.height):
        for x in range(canvas.width):
            if 0 <= x < canvas.width and 0 <= y < canvas.height:
                r, g, b, a = canvas_rgba_data[x, y]
                canvas_data[x, y] = (r, g, b)


def add_shadow_below_phone(
    canvas: Image.Image, phone_rect: Tuple[int, int, int, int]
) -> None:
    """Add gaussian shadow below phone frame."""
    x0, y0, x1, y1 = phone_rect

    # Create shadow layer
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)

    # Shadow ellipse below phone
    shadow_y_top = y1 - SHADOW_SPREAD
    shadow_y_bottom = y1 + SHADOW_SPREAD + SHADOW_Y_OFFSET
    shadow_x_left = x0 - SHADOW_SPREAD
    shadow_x_right = x1 + SHADOW_SPREAD

    # Draw shadow as ellipse
    shadow_draw.ellipse(
        [shadow_x_left, shadow_y_top, shadow_x_right, shadow_y_bottom],
        fill=(0, 0, 0, 80),
    )

    # Blur and composite
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=SHADOW_BLUR))

    if canvas.mode != "RGBA":
        canvas_rgba = canvas.convert("RGBA")
    else:
        canvas_rgba = canvas.copy()

    canvas_rgba = Image.alpha_composite(canvas_rgba, shadow)

    # Copy back to original
    canvas.paste(canvas_rgba.convert("RGB"))


def draw_text_headline(
    canvas: Image.Image, text: str, x: int, y: int, max_width: int, lang: str = "en"
) -> int:
    """
    Draw headline with proper line-height and centering.

    Returns: y position of bottom of headline
    """
    draw = ImageDraw.Draw(canvas)
    font = load_font("headline", FONT_SIZE_HEADLINE, lang)

    # Split by explicit \n
    lines = text.split("\n")

    # Calculate total height
    line_spacing = int(FONT_SIZE_HEADLINE * LINE_HEIGHT_HEADLINE)
    total_height = line_spacing * len(lines)

    # Start y to center text block
    current_y = y

    for line in lines:
        # Get text bounding box for centering
        bbox = draw.textbbox((0, 0), line, font=font)
        text_width = bbox[2] - bbox[0]
        text_x = x - text_width // 2  # Center horizontally

        # Draw with antialiasing
        draw.text(
            (text_x, current_y),
            line,
            fill=COLOR_TEXT_HEADLINE,
            font=font,
        )

        current_y += line_spacing

    return current_y


def draw_text_subhead(
    canvas: Image.Image, text: str, x: int, y: int, max_width: int, lang: str = "en"
) -> int:
    """
    Draw subheading with proper line-height and centering.

    Returns: y position of bottom of subheading
    """
    draw = ImageDraw.Draw(canvas)
    font = load_font("subhead", FONT_SIZE_SUBHEAD, lang)

    # Split text into lines respecting max_width
    words = text.split()
    lines = []
    current_line = []

    for word in words:
        current_line.append(word)
        test_text = " ".join(current_line)
        bbox = draw.textbbox((0, 0), test_text, font=font)
        test_width = bbox[2] - bbox[0]

        if test_width > max_width:
            current_line.pop()
            if current_line:
                lines.append(" ".join(current_line))
            current_line = [word]

    if current_line:
        lines.append(" ".join(current_line))

    line_spacing = int(FONT_SIZE_SUBHEAD * LINE_HEIGHT_SUBHEAD)
    current_y = y

    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        text_width = bbox[2] - bbox[0]
        text_x = x - text_width // 2

        # Convert color tuple with alpha to RGB for draw.text
        draw.text(
            (text_x, current_y),
            line,
            fill=COLOR_TEXT_HEADLINE,  # Using white, alpha handled separately
            font=font,
        )

        current_y += line_spacing

    return current_y


def draw_usp_badge(canvas: Image.Image, text: str, y: int) -> int:
    """
    Draw orange USP badge pill.

    Returns: y position of bottom of badge
    """
    draw = ImageDraw.Draw(canvas)
    font = load_font("badge", FONT_SIZE_BADGE, "en")

    # Measure text
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Calculate badge dimensions
    badge_padding_h = 34
    badge_padding_v = 14
    badge_width = text_width + badge_padding_h * 2
    badge_height = text_height + badge_padding_v * 2
    badge_radius = badge_height // 2

    # Center badge
    badge_x0 = (CANVAS_W - badge_width) // 2
    badge_y0 = y
    badge_x1 = badge_x0 + badge_width
    badge_y1 = badge_y0 + badge_height

    # Draw badge with rounded corners
    draw.rounded_rectangle(
        [badge_x0, badge_y0, badge_x1, badge_y1],
        radius=badge_radius,
        fill=COLOR_BADGE_BG,
    )

    # Add glow effect
    glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.rounded_rectangle(
        [badge_x0, badge_y0, badge_x1, badge_y1],
        radius=badge_radius,
        fill=(255, 112, 67, 80),  # Orange with 30% opacity for glow
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=20))

    if canvas.mode != "RGBA":
        canvas_rgba = canvas.convert("RGBA")
    else:
        canvas_rgba = canvas.copy()

    canvas_rgba = Image.alpha_composite(canvas_rgba, glow)
    canvas.paste(canvas_rgba.convert("RGB"))

    # Draw text centered in badge
    text_x = badge_x0 + badge_padding_h + (text_width // 2)
    text_y = badge_y0 + badge_padding_v

    draw.text(
        (text_x - (bbox[2] - bbox[0]) // 2, text_y),
        text,
        fill=COLOR_BADGE_TEXT,
        font=font,
    )

    return badge_y1


def load_and_crop_screen(raw_path: Path) -> Image.Image:
    """
    Load raw screenshot and crop status bar + nav.

    Raw size: 1260×2844
    Crop: 100px top (status) + 195px bottom (nav) = 1260×2549
    """
    img = Image.open(raw_path)

    # Crop: left, top, right, bottom
    img = img.crop((0, 100, 1260, 2844 - 195))

    return img


def make_mockup(
    lang: str,
    screen_name: str,
    headline: str,
    subhead: str,
    usp_badge: Optional[str] = None,
) -> Path:
    """
    Generate single mockup.

    Args:
        lang: Language code (en, ru, etc.)
        screen_name: Screen name (01_home, 02_add_top, etc.)
        headline: Headline text (with \\n for line breaks)
        subhead: Subheading text
        usp_badge: Optional USP badge text (only for 03_add_hands)

    Returns: Path to generated PNG
    """
    print(f"Generating {lang}/{screen_name}...")

    # Create output directory
    out_dir = OUT_ROOT / lang
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{screen_name}.png"

    # ========================================================================
    # Step 1: Create gradient background
    # ========================================================================
    canvas = create_gradient_canvas(CANVAS_W, CANVAS_H, COLOR_BG_TOP, COLOR_BG_MID, COLOR_BG_BTM)

    # ========================================================================
    # Step 2: Add noise texture
    # ========================================================================
    canvas = add_noise_texture(canvas, opacity=0.045)

    # ========================================================================
    # Step 3: Calculate layout positions
    # ========================================================================
    headline_y = HEADLINE_TOP_Y
    subhead_y = draw_text_headline(canvas, headline, CANVAS_W // 2, headline_y, CANVAS_W - 140, lang)
    subhead_y += SUBHEAD_BELOW_HEADLINE

    subhead_end_y = draw_text_subhead(canvas, subhead, CANVAS_W // 2, subhead_y, CANVAS_W - 140, lang)

    # Determine phone position
    phone_y = subhead_end_y + BADGE_BELOW_SUBHEAD + (100 if usp_badge else 50)

    # If USP badge, draw it
    if usp_badge:
        badge_y = subhead_end_y + BADGE_BELOW_SUBHEAD
        badge_bottom_y = draw_usp_badge(canvas, usp_badge, badge_y)
        phone_y = badge_bottom_y + 50

    # ========================================================================
    # Step 4: Load and prepare screen content
    # ========================================================================
    raw_path = RAW_ROOT / lang / f"{screen_name}.png"
    screen_img = load_and_crop_screen(raw_path)

    # ========================================================================
    # Step 5: Draw phone frame with screen content
    # ========================================================================
    screen_rect = draw_phone_frame(canvas, screen_img, PHONE_PADDING, phone_y)

    # ========================================================================
    # Step 6: Add glass reflection
    # ========================================================================
    add_glass_reflection(canvas, screen_rect)

    # ========================================================================
    # Step 7: Add shadow below phone
    # ========================================================================
    add_shadow_below_phone(canvas, screen_rect)

    # ========================================================================
    # Step 8: Save
    # ========================================================================
    canvas.save(out_path, "PNG", quality=95, optimize=True)
    print(f"[OK] Saved: {out_path}")

    return out_path


def generate_all_en_mockups() -> None:
    """Generate all 6 English mockups."""
    screens = [
        "01_home",
        "02_add_top",
        "03_add_hands",
        "04_history",
        "05_add_bottom",
        "06_report",
    ]

    for screen in screens:
        headline, subhead = HEADLINES["en"][screen]
        usp = USP_BADGES["en"] if screen == "03_add_hands" else None

        make_mockup("en", screen, headline, subhead, usp)


if __name__ == "__main__":
    print("=" * 70)
    print("Premium App Store Mockup Generator v3")
    print("=" * 70)

    # Generate all EN mockups
    generate_all_en_mockups()

    print("\n" + "=" * 70)
    print("[OK] All mockups generated successfully!")
    print("=" * 70)
