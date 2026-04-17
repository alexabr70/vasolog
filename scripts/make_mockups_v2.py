#!/usr/bin/env py
"""
VasoLog Mockup Generator v2 - AppGallery-ready конверсионные mockup'ы.

Design philosophy (based on April 2026 benchmarks):
- 90% users decide in first 3 screenshots (SplitMetrics 2025)
- Localized screens = +128% downloads, 2.3x CVR (asomobile 2025)
- Medical trust signals > fake ratings
- Benefit-driven headlines, not feature descriptions

Layout (1260x2798 canvas, 9:19.5 device ratio):
- Top 12%: purple brand gradient with subtle shine
- 13-26%: BIG bold localized headline (92px) + subhead (48px)
- 27-97%: phone screenshot with rounded corners + cinematic shadow
- 97-100%: gradient fade
- Special: 03_add_hands gets orange accent glow (USP highlight)
"""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path
import sys, io

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace", line_buffering=True)

RAW = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw")
OUT = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/mockups_v2")
OUT.mkdir(parents=True, exist_ok=True)

# Canvas 9:19.5 - совпадает с device (no scaling = max sharpness)
CANVAS_W, CANVAS_H = 1260, 2798

# Brand colors (VasoLog purple gradient from lib/utils/constants.dart)
GRAD_START = (92, 107, 192)   # #5C6BC0 indigo
GRAD_END = (94, 53, 177)      # #5E35B1 deep purple
WHITE = (255, 255, 255, 255)
SHADOW = (0, 0, 0, 90)
# Accent color - orange (FAB button) для USP badge
ACCENT = (255, 112, 67)       # #FF7043

# Обрезка raw (1260x2844): убираем status (100px top) + nav bar (195px bottom)
# = content area 1260x2549
STATUS_BAR_H = 100
NAV_BAR_H = 195

# 6 типов screens
SCREEN_TYPES = ["01_home", "02_add_top", "03_add_hands", "04_history", "05_add_bottom", "06_report"]

# Headlines - benefit-driven, culturally adapted. Formats: (headline, subhead).
# Headline = 2 lines max. Subhead = 1 line.
HEADLINES = {
    "en": {
        "01_home":        ("Take control of\nyour Raynaud's", "Weather, stats, trends - one place"),
        "02_add_top":     ("Log an attack in\n10 seconds", "Severity, color, triggers - fast"),
        "03_add_hands":   ("Mark exactly where\nit hurts", "Unique finger-level tracking"),
        "04_history":     ("See your weekly\npattern", "Know what triggers attacks"),
        "05_add_bottom":  ("Save & keep\ntracking", "Photos, notes, full history"),
        "06_report":      ("PDF report for\nyour doctor", "One tap - share everything"),
    },
    "ru": {
        "01_home":        ("Синдром Рейно\nпод контролем", "Погода, статистика, тренды"),
        "02_add_top":     ("Запиши приступ\nза 10 секунд", "Тяжесть, цвет, триггеры"),
        "03_add_hands":   ("Отметь где именно\nбольно", "Точность до каждого пальца"),
        "04_history":     ("Виже свою\nстатистику", "Пойми что провоцирует приступ"),
        "05_add_bottom":  ("Сохраняй и\nотслеживай", "Фото, заметки, полная история"),
        "06_report":      ("PDF-отчёт для\nврача", "Поделись в один клик"),
    },
    "de": {
        "01_home":        ("Raynaud unter\nKontrolle", "Wetter, Statistik, Trends"),
        "02_add_top":     ("Anfall in 10\nSekunden erfassen", "Schwere, Farbe, Auslöser"),
        "03_add_hands":   ("Markieren Sie\njeden Finger", "Fingergenaue Erfassung"),
        "04_history":     ("Ihr Wochen-\nmuster erkennen", "Verstehen was Anfälle auslöst"),
        "05_add_bottom":  ("Speichern und\nweiter verfolgen", "Fotos, Notizen, Verlauf"),
        "06_report":      ("PDF-Bericht für\nIhren Arzt", "Mit einem Tipp teilen"),
    },
    "fr": {
        "01_home":        ("Votre Raynaud\nsous contrôle", "Météo, stats, tendances"),
        "02_add_top":     ("Noter une crise\nen 10 secondes", "Gravité, couleur, déclencheurs"),
        "03_add_hands":   ("Marquez chaque\ndoigt touché", "Précision doigt par doigt"),
        "04_history":     ("Découvrez votre\nrythme hebdo", "Identifiez vos déclencheurs"),
        "05_add_bottom":  ("Enregistrez et\ncontinuez", "Photos, notes, historique"),
        "06_report":      ("Rapport PDF\npour le médecin", "Partagez en un clic"),
    },
    "es": {
        "01_home":        ("Tu Raynaud\nbajo control", "Clima, estadísticas, tendencias"),
        "02_add_top":     ("Registra una crisis\nen 10 segundos", "Gravedad, color, desencadenantes"),
        "03_add_hands":   ("Marca exactamente\ndónde duele", "Precisión dedo por dedo"),
        "04_history":     ("Descubre tu\npatrón semanal", "Conoce tus desencadenantes"),
        "05_add_bottom":  ("Guarda y sigue\nrastreando", "Fotos, notas, historial"),
        "06_report":      ("Informe PDF\npara tu médico", "Comparte con un toque"),
    },
    "pt": {
        "01_home":        ("O seu Raynaud\nsob controlo", "Tempo, estatísticas, tendências"),
        "02_add_top":     ("Registe uma crise\nem 10 segundos", "Gravidade, cor, gatilhos"),
        "03_add_hands":   ("Marque onde\ndói exatamente", "Precisão dedo a dedo"),
        "04_history":     ("Descubra o seu\npadrão semanal", "Conheça os gatilhos"),
        "05_add_bottom":  ("Guarde e\ncontinue", "Fotos, notas, histórico"),
        "06_report":      ("Relatório PDF\npara o médico", "Partilhe com um toque"),
    },
    "it": {
        "01_home":        ("Il tuo Raynaud\nsotto controllo", "Meteo, statistiche, tendenze"),
        "02_add_top":     ("Registra una crisi\nin 10 secondi", "Gravità, colore, fattori"),
        "03_add_hands":   ("Segna esattamente\ndove fa male", "Precisione dito per dito"),
        "04_history":     ("Scopri il tuo\nritmo settimanale", "Scopri i tuoi fattori"),
        "05_add_bottom":  ("Salva e\ncontinua", "Foto, note, cronologia"),
        "06_report":      ("Rapporto PDF\nper il medico", "Condividi con un tocco"),
    },
    "sv": {
        "01_home":        ("Raynaud under\nkontroll", "Väder, statistik, trender"),
        "02_add_top":     ("Logga ett anfall\npå 10 sekunder", "Svårighet, färg, utlösare"),
        "03_add_hands":   ("Markera exakt\nvar det gör ont", "Finger-precision"),
        "04_history":     ("Se ditt vecko-\nmönster", "Förstå vad som utlöser"),
        "05_add_bottom":  ("Spara och\nfortsätt", "Foton, anteckningar, historik"),
        "06_report":      ("PDF-rapport\ntill läkaren", "Dela med ett tryck"),
    },
    "fi": {
        "01_home":        ("Raynaud\nhallinnassa", "Sää, tilastot, trendit"),
        "02_add_top":     ("Kirjaa kohtaus\n10 sekunnissa", "Vakavuus, väri, laukaisijat"),
        "03_add_hands":   ("Merkitse tarkasti\nmissä sattuu", "Sormikohtainen seuranta"),
        "04_history":     ("Näe viikko-\nkuviosi", "Tunne laukaisijasi"),
        "05_add_bottom":  ("Tallenna ja\njatka", "Kuvat, muistiinpanot, historia"),
        "06_report":      ("PDF-raportti\nlääkärille", "Jaa yhdellä napautuksella"),
    },
    "nb": {
        "01_home":        ("Raynaud under\nkontroll", "Vær, statistikk, trender"),
        "02_add_top":     ("Logg et anfall\npå 10 sekunder", "Alvor, farge, utløsere"),
        "03_add_hands":   ("Merk nøyaktig\nhvor det gjør vondt", "Finger-presisjon"),
        "04_history":     ("Se ditt uke-\nmønster", "Forstå utløserne dine"),
        "05_add_bottom":  ("Lagre og\nfortsett", "Foto, notater, historikk"),
        "06_report":      ("PDF-rapport\ntil legen", "Del med ett trykk"),
    },
    "da": {
        "01_home":        ("Raynaud under\nkontrol", "Vejr, statistik, tendenser"),
        "02_add_top":     ("Log et anfald\npå 10 sekunder", "Sværhed, farve, udløsere"),
        "03_add_hands":   ("Markér præcist\nhvor det gør ondt", "Finger-præcision"),
        "04_history":     ("Se dit uge-\nmønster", "Forstå dine udløsere"),
        "05_add_bottom":  ("Gem og\nfortsæt", "Fotos, noter, historik"),
        "06_report":      ("PDF-rapport\ntil lægen", "Del med ét tryk"),
    },
    "nl": {
        "01_home":        ("Raynaud onder\ncontrole", "Weer, statistieken, trends"),
        "02_add_top":     ("Log een aanval\nin 10 seconden", "Ernst, kleur, triggers"),
        "03_add_hands":   ("Markeer precies\nwaar het pijn doet", "Vinger-precisie"),
        "04_history":     ("Zie je week-\npatroon", "Ken je triggers"),
        "05_add_bottom":  ("Opslaan en\ndoorgaan", "Foto's, notities, geschiedenis"),
        "06_report":      ("PDF-rapport\nvoor je arts", "Deel met één tik"),
    },
    "pl": {
        "01_home":        ("Raynaud pod\nkontrolą", "Pogoda, statystyki, trendy"),
        "02_add_top":     ("Zapisz atak\nw 10 sekund", "Nasilenie, kolor, wyzwalacze"),
        "03_add_hands":   ("Zaznacz dokładnie\ngdzie boli", "Dokładność co do palca"),
        "04_history":     ("Odkryj swój\nrytm tygodnia", "Poznaj swoje wyzwalacze"),
        "05_add_bottom":  ("Zapisz i\nśledź dalej", "Zdjęcia, notatki, historia"),
        "06_report":      ("Raport PDF\ndla lekarza", "Udostępnij jednym dotknięciem"),
    },
    "cs": {
        "01_home":        ("Raynaud pod\nkontrolou", "Počasí, statistiky, trendy"),
        "02_add_top":     ("Zaznamenej záchvat\nza 10 sekund", "Závažnost, barva, spouštěče"),
        "03_add_hands":   ("Označ přesně\nkde to bolí", "Přesnost na prst"),
        "04_history":     ("Objev svůj\ntýdenní vzor", "Pochop své spouštěče"),
        "05_add_bottom":  ("Ulož a\npokračuj", "Fotky, poznámky, historie"),
        "06_report":      ("PDF zpráva\npro lékaře", "Sdílej jedním klepnutím"),
    },
    "hu": {
        "01_home":        ("Raynaud\nkontroll alatt", "Időjárás, statisztika, trendek"),
        "02_add_top":     ("Rögzíts rohamot\n10 másodperc alatt", "Súlyosság, szín, kiváltók"),
        "03_add_hands":   ("Jelöld pontosan\nhol fáj", "Ujj-pontosságú követés"),
        "04_history":     ("Fedezd fel\nheti ritmusod", "Ismerd ki a kiváltókat"),
        "05_add_bottom":  ("Mentsd és\nfolytasd", "Fotók, jegyzetek, előzmények"),
        "06_report":      ("PDF-jelentés\nazorvosnak", "Oszd meg egy érintéssel"),
    },
    "uk": {
        "01_home":        ("Рейно під\nконтролем", "Погода, статистика, тренди"),
        "02_add_top":     ("Запиши напад\nза 10 секунд", "Тяжкість, колір, тригери"),
        "03_add_hands":   ("Познач точно\nде болить", "Точність до пальця"),
        "04_history":     ("Знайди свій\nтижневий ритм", "Дізнайся свої тригери"),
        "05_add_bottom":  ("Зберігай і\nвідстежуй", "Фото, нотатки, історія"),
        "06_report":      ("PDF-звіт\nдля лікаря", "Поділися одним дотиком"),
    },
    "ja": {
        "01_home":        ("レイノー現象を\nしっかり管理", "天気・統計・トレンド"),
        "02_add_top":     ("発作を10秒で\n記録", "重症度・色・誘因"),
        "03_add_hands":   ("痛む指を\n正確にタップ", "指ごとの精密記録"),
        "04_history":     ("週ごとの\nパターンを発見", "誘因を理解しよう"),
        "05_add_bottom":  ("保存して\n記録継続", "写真・メモ・履歴"),
        "06_report":      ("医師向け\nPDFレポート", "ワンタップで共有"),
    },
    "ko": {
        "01_home":        ("레이노를\n완벽하게 관리", "날씨·통계·트렌드"),
        "02_add_top":     ("발작을 10초\n안에 기록", "심각도·색상·유발 요인"),
        "03_add_hands":   ("아픈 손가락을\n정확히 선택", "손가락별 정밀 기록"),
        "04_history":     ("주간 패턴\n확인하기", "유발 요인 파악"),
        "05_add_bottom":  ("저장하고\n계속 기록", "사진·메모·전체 기록"),
        "06_report":      ("의사용\nPDF 보고서", "한 번에 공유"),
    },
}


# ── Font selection ───────────────────────────────────────────────────────────

def find_font(lang: str, size: int, bold: bool = True) -> ImageFont.FreeTypeFont:
    # CJK: specific fonts for Japanese/Korean/Chinese
    if lang == "ja":
        for path in ["C:/Windows/Fonts/YuGothB.ttc",
                     "C:/Windows/Fonts/meiryob.ttc",
                     "C:/Windows/Fonts/msgothic.ttc"]:
            if Path(path).exists():
                return ImageFont.truetype(path, size)
    if lang == "ko":
        for path in ["C:/Windows/Fonts/malgunbd.ttf",
                     "C:/Windows/Fonts/malgun.ttf",
                     "C:/Windows/Fonts/gulim.ttc"]:
            if Path(path).exists():
                return ImageFont.truetype(path, size)
    # Default: Segoe UI Bold (supports Cyrillic/Latin/diacritics)
    candidates = (["C:/Windows/Fonts/segoeuib.ttf",
                   "C:/Windows/Fonts/arialbd.ttf"]
                  if bold else
                  ["C:/Windows/Fonts/segoeui.ttf",
                   "C:/Windows/Fonts/arial.ttf"])
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


# ── Drawing helpers ──────────────────────────────────────────────────────────

def draw_gradient_bg(w, h) -> Image.Image:
    """Vertical brand gradient + subtle shine in top 30%."""
    bg = Image.new("RGB", (w, h), GRAD_START)
    d = ImageDraw.Draw(bg)
    for y in range(h):
        t = y / h
        r = int(GRAD_START[0] * (1 - t) + GRAD_END[0] * t)
        g = int(GRAD_START[1] * (1 - t) + GRAD_END[1] * t)
        b = int(GRAD_START[2] * (1 - t) + GRAD_END[2] * t)
        d.line([(0, y), (w, y)], fill=(r, g, b))
    return bg


def rounded_crop(shot: Image.Image, radius: int = 72) -> Image.Image:
    """Обрезает raw screenshot (1260x2844) до content (1260x2549) + rounded corners."""
    w, h = shot.size
    cropped = shot.crop((0, STATUS_BAR_H, w, h - NAV_BAR_H))
    mask = Image.new("L", cropped.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([(0, 0), cropped.size], radius=radius, fill=255)
    out = Image.new("RGBA", cropped.size, (0, 0, 0, 0))
    out.paste(cropped, (0, 0), mask)
    return out


def wrap_text(text: str, font, max_w: int, draw) -> list[str]:
    """Wrap by explicit \\n first, then by word-wrap if too wide."""
    result = []
    for raw_line in text.split("\n"):
        words = raw_line.split()
        if not words:
            result.append("")
            continue
        current = ""
        for word in words:
            cand = f"{current} {word}".strip()
            if draw.textlength(cand, font=font) <= max_w:
                current = cand
            else:
                if current:
                    result.append(current)
                current = word
        if current:
            result.append(current)
    return result


def make_mockup(raw_path: Path, lang: str, screen: str, out_path: Path) -> None:
    """Собирает один mockup."""
    shot = Image.open(raw_path).convert("RGBA")
    # Scale: raw 1260x2844 → crop → 1260x2549
    shot_crop = rounded_crop(shot, radius=72)
    # Downscale чтобы поместиться в canvas с padding
    device_w = CANVAS_W - 160  # 80px padding each side
    sw, sh = shot_crop.size
    scale = device_w / sw
    new_w = int(sw * scale)
    new_h = int(sh * scale)
    shot_scaled = shot_crop.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # Build canvas
    canvas = draw_gradient_bg(CANVAS_W, CANVAS_H).convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    # Headlines
    if lang not in HEADLINES or screen not in HEADLINES[lang]:
        print(f"  [WARN] missing headline for {lang}/{screen}, using en fallback")
        headline, subhead = HEADLINES["en"].get(screen, ("", ""))
    else:
        headline, subhead = HEADLINES[lang][screen]

    h_font = find_font(lang, 92, bold=True)
    s_font = find_font(lang, 48, bold=False)

    max_text_w = CANVAS_W - 140
    h_lines = wrap_text(headline, h_font, max_text_w, draw)
    s_lines = wrap_text(subhead, s_font, max_text_w, draw)

    # Render headline (top-centered)
    y = 140
    for line in h_lines:
        w = draw.textlength(line, font=h_font)
        draw.text(((CANVAS_W - w) / 2, y), line, font=h_font, fill=WHITE)
        y += int(h_font.size * 1.12)
    y += 20
    for line in s_lines:
        w = draw.textlength(line, font=s_font)
        draw.text(((CANVAS_W - w) / 2, y), line, font=s_font, fill=(255, 255, 255, 230))
        y += int(s_font.size * 1.25)

    # USP badge for 03_add_hands
    if screen == "03_add_hands":
        badge_text = {
            "en": "UNIQUE",
            "ru": "УНИКАЛЬНО",
            "de": "EINZIGARTIG",
            "fr": "UNIQUE",
            "es": "ÚNICO",
            "pt": "ÚNICO",
            "it": "UNICO",
            "sv": "UNIKT",
            "fi": "AINUTLAATUINEN",
            "nb": "UNIKT",
            "da": "UNIKT",
            "nl": "UNIEK",
            "pl": "UNIKALNE",
            "cs": "JEDINEČNÉ",
            "hu": "EGYEDI",
            "uk": "УНІКАЛЬНО",
            "ja": "独自機能",
            "ko": "독점 기능",
        }.get(lang, "UNIQUE")
        b_font = find_font(lang, 40, bold=True)
        b_w = draw.textlength(badge_text, font=b_font)
        badge_padding = 30
        badge_rect_w = b_w + badge_padding * 2
        badge_rect_h = 60
        bx = (CANVAS_W - badge_rect_w) // 2
        by = y + 10
        draw.rounded_rectangle(
            [(bx, by), (bx + badge_rect_w, by + badge_rect_h)],
            radius=30, fill=ACCENT,
        )
        draw.text((bx + badge_padding, by + 8), badge_text, font=b_font, fill=WHITE)
        y += badge_rect_h + 20

    # Shadow for phone
    shadow = Image.new("RGBA", (new_w + 160, new_h + 160), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([(40, 80), (new_w + 120, new_h + 120)], radius=72, fill=SHADOW)
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=40))

    # Position phone centered
    phone_x = (CANVAS_W - new_w) // 2
    phone_y = y + 80
    # Clip if overflows
    if phone_y + new_h > CANVAS_H - 60:
        new_h_clip = CANVAS_H - 60 - phone_y
        shot_scaled = shot_scaled.crop((0, 0, new_w, new_h_clip))

    canvas.alpha_composite(shadow, (phone_x - 80, phone_y - 80))
    canvas.alpha_composite(shot_scaled, (phone_x, phone_y))

    canvas.convert("RGB").save(out_path, "PNG", optimize=True)


def main():
    langs = sorted([d.name for d in RAW.iterdir() if d.is_dir()])
    print(f"Mockup v2 for {len(langs)} languages")
    total = 0
    for lang in langs:
        out_dir = OUT / lang
        out_dir.mkdir(parents=True, exist_ok=True)
        for screen in SCREEN_TYPES:
            raw = RAW / lang / f"{screen}.png"
            if not raw.exists():
                print(f"  SKIP {lang}/{screen}: raw not found")
                continue
            out = out_dir / f"{screen}.png"
            try:
                make_mockup(raw, lang, screen, out)
                total += 1
            except Exception as e:
                print(f"  [ERR] {lang}/{screen}: {e}")
        print(f"  {lang}: done")
    print(f"\nTotal mockups: {total}")


if __name__ == "__main__":
    main()
