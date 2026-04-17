#!/usr/bin/env python3
"""
VasoLog AppGallery Mockup Generator
Превращает raw скриншоты в конверсионные AppGallery-ready мокапы:
- Brand-gradient фон (indigo + purple)
- Локализованный headline сверху
- Скриншот в device-frame с rounded corners + тенью
- Формат 1080x2340 (Huawei AppGallery portrait phone)

Запуск: py scripts/make_mockups.py
"""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path

RAW = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw")
OUT = Path("D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/final")
OUT.mkdir(parents=True, exist_ok=True)

# Canvas под Huawei AppGallery phone (portrait)
CANVAS_W, CANVAS_H = 1080, 2340

# Брендовые цвета (из lib/utils/constants.dart)
GRAD_START = (92, 107, 192)   # #5C6BC0 indigo
GRAD_END = (94, 53, 177)      # #5E35B1 deeper purple
WHITE = (255, 255, 255, 255)
SHADOW = (0, 0, 0, 80)

# Обрезка: убираем Android status bar и nav bar
STATUS_BAR_H = 100   # пикселей в source 1260x2844
NAV_BAR_H = 120

# Локализованные заголовки: 4 screen × 18 lang
HEADLINES = {
    "en": {
        "01_home": ("Your Raynaud's at a glance", "Weather + stats + trends"),
        "02_add_episode": ("Log an attack in seconds", "Severity, color, fingers, triggers"),
        "03_history": ("Complete attack history", "Weekly charts and statistics"),
        "04_report": ("PDF report for your doctor", "Share with one tap"),
    },
    "ru": {
        "01_home": ("Синдром Рейно под контролем", "Погода + статистика + тренды"),
        "02_add_episode": ("Запиши приступ за секунды", "Тяжесть, цвет, пальцы, триггеры"),
        "03_history": ("Полная история приступов", "Графики по неделям и статистика"),
        "04_report": ("PDF-отчёт для врача", "Отправить в один клик"),
    },
    "de": {
        "01_home": ("Raynaud auf einen Blick", "Wetter + Statistik + Trends"),
        "02_add_episode": ("Anfall in Sekunden erfassen", "Schwere, Farbe, Finger, Auslöser"),
        "03_history": ("Vollständige Anfallsverlauf", "Wochendiagramme und Statistik"),
        "04_report": ("PDF-Bericht für den Arzt", "Mit einem Tipp teilen"),
    },
    "fr": {
        "01_home": ("Raynaud en un coup d'œil", "Météo + statistiques + tendances"),
        "02_add_episode": ("Enregistrez une crise en secondes", "Sévérité, couleur, doigts, déclencheurs"),
        "03_history": ("Historique complet des crises", "Graphiques hebdomadaires et stats"),
        "04_report": ("Rapport PDF pour votre médecin", "Partagez en un clic"),
    },
    "es": {
        "01_home": ("Tu Raynaud de un vistazo", "Clima + estadísticas + tendencias"),
        "02_add_episode": ("Registra una crisis en segundos", "Gravedad, color, dedos, desencadenantes"),
        "03_history": ("Historial completo de crisis", "Gráficos semanales y estadísticas"),
        "04_report": ("Informe PDF para tu médico", "Comparte con un toque"),
    },
    "pt": {
        "01_home": ("O seu Raynaud num relance", "Clima + estatísticas + tendências"),
        "02_add_episode": ("Registe uma crise em segundos", "Gravidade, cor, dedos, gatilhos"),
        "03_history": ("Histórico completo de crises", "Gráficos semanais e estatísticas"),
        "04_report": ("Relatório PDF para o médico", "Partilhe com um toque"),
    },
    "it": {
        "01_home": ("Il tuo Raynaud a colpo d'occhio", "Meteo + statistiche + tendenze"),
        "02_add_episode": ("Registra una crisi in pochi secondi", "Gravità, colore, dita, fattori"),
        "03_history": ("Storico completo delle crisi", "Grafici settimanali e statistiche"),
        "04_report": ("Rapporto PDF per il tuo medico", "Condividi con un tocco"),
    },
    "sv": {
        "01_home": ("Din Raynaud med en blick", "Väder + statistik + trender"),
        "02_add_episode": ("Logga ett anfall på sekunder", "Svårighet, färg, fingrar, utlösare"),
        "03_history": ("Komplett anfallshistorik", "Veckodiagram och statistik"),
        "04_report": ("PDF-rapport till din läkare", "Dela med ett tryck"),
    },
    "fi": {
        "01_home": ("Raynaud yhdellä silmäyksellä", "Sää + tilastot + trendit"),
        "02_add_episode": ("Kirjaa kohtaus sekunneissa", "Vakavuus, väri, sormet, laukaisijat"),
        "03_history": ("Kohtausten täysi historia", "Viikkokaaviot ja tilastot"),
        "04_report": ("PDF-raportti lääkärillesi", "Jaa yhdellä napautuksella"),
    },
    "nb": {
        "01_home": ("Raynaud med ett blikk", "Vær + statistikk + trender"),
        "02_add_episode": ("Logg et anfall på sekunder", "Alvor, farge, fingre, utløsere"),
        "03_history": ("Komplett anfallshistorikk", "Ukesdiagrammer og statistikk"),
        "04_report": ("PDF-rapport til legen din", "Del med ett trykk"),
    },
    "da": {
        "01_home": ("Din Raynaud på et blik", "Vejr + statistik + tendenser"),
        "02_add_episode": ("Log et anfald på sekunder", "Sværhed, farve, fingre, udløsere"),
        "03_history": ("Komplet anfaldshistorik", "Ugediagrammer og statistik"),
        "04_report": ("PDF-rapport til din læge", "Del med ét tryk"),
    },
    "nl": {
        "01_home": ("Jouw Raynaud in één oogopslag", "Weer + statistieken + trends"),
        "02_add_episode": ("Log een aanval in seconden", "Ernst, kleur, vingers, triggers"),
        "03_history": ("Volledige aanvalgeschiedenis", "Weekgrafieken en statistieken"),
        "04_report": ("PDF-rapport voor je arts", "Deel met één tik"),
    },
    "pl": {
        "01_home": ("Twój Raynaud w skrócie", "Pogoda + statystyki + trendy"),
        "02_add_episode": ("Zapisz atak w kilka sekund", "Nasilenie, kolor, palce, wyzwalacze"),
        "03_history": ("Pełna historia ataków", "Wykresy tygodniowe i statystyki"),
        "04_report": ("Raport PDF dla lekarza", "Udostępnij jednym dotknięciem"),
    },
    "cs": {
        "01_home": ("Váš Raynaud na první pohled", "Počasí + statistika + trendy"),
        "02_add_episode": ("Zaznamenej záchvat za sekundy", "Závažnost, barva, prsty, spouštěče"),
        "03_history": ("Kompletní historie záchvatů", "Týdenní grafy a statistiky"),
        "04_report": ("PDF zpráva pro lékaře", "Sdílej jedním klepnutím"),
    },
    "hu": {
        "01_home": ("A Raynaud-od egy pillantásra", "Időjárás + statisztika + trendek"),
        "02_add_episode": ("Rögzíts rohamot másodpercek alatt", "Súlyosság, szín, ujjak, kiváltók"),
        "03_history": ("Teljes rohamtörténet", "Heti grafikonok és statisztikák"),
        "04_report": ("PDF-jelentés orvosodnak", "Oszd meg egy érintéssel"),
    },
    "uk": {
        "01_home": ("Ваш Рейно під контролем", "Погода + статистика + тренди"),
        "02_add_episode": ("Запишіть напад за секунди", "Тяжкість, колір, пальці, тригери"),
        "03_history": ("Повна історія нападів", "Графіки по тижнях і статистика"),
        "04_report": ("PDF-звіт для лікаря", "Поділіться одним дотиком"),
    },
    "ja": {
        "01_home": ("レイノー現象を一目で", "天気・統計・トレンド"),
        "02_add_episode": ("発作を数秒で記録", "重症度・色・指・誘因"),
        "03_history": ("完全な発作履歴", "週グラフと統計"),
        "04_report": ("医師向けPDFレポート", "ワンタップで共有"),
    },
    "ko": {
        "01_home": ("한눈에 보는 레이노", "날씨 + 통계 + 트렌드"),
        "02_add_episode": ("몇 초 만에 발작 기록", "심각도, 색상, 손가락, 유발 요인"),
        "03_history": ("전체 발작 기록", "주간 차트와 통계"),
        "04_report": ("의사용 PDF 보고서", "한 번에 공유"),
    },
}


def find_font(lang: str, size: int) -> ImageFont.FreeTypeFont:
    """Возвращает шрифт, поддерживающий CJK если нужно."""
    # Для CJK пробуем встроенные шрифты Windows
    if lang in ("ja", "ko"):
        for candidate in [
            "C:/Windows/Fonts/YuGothB.ttc",
            "C:/Windows/Fonts/malgun.ttf",
            "C:/Windows/Fonts/msgothic.ttc",
        ]:
            if Path(candidate).exists():
                return ImageFont.truetype(candidate, size)
    # Для остальных - Segoe UI (Windows) -> Arial
    for candidate in [
        "C:/Windows/Fonts/segoeuib.ttf",  # bold
        "C:/Windows/Fonts/arialbd.ttf",
    ]:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def draw_gradient_bg() -> Image.Image:
    """Brand gradient фон"""
    bg = Image.new("RGB", (CANVAS_W, CANVAS_H), GRAD_START)
    draw = ImageDraw.Draw(bg)
    for y in range(CANVAS_H):
        t = y / CANVAS_H
        r = int(GRAD_START[0] * (1 - t) + GRAD_END[0] * t)
        g = int(GRAD_START[1] * (1 - t) + GRAD_END[1] * t)
        b = int(GRAD_START[2] * (1 - t) + GRAD_END[2] * t)
        draw.line([(0, y), (CANVAS_W, y)], fill=(r, g, b))
    return bg


def rounded_shot(shot: Image.Image, radius: int = 40) -> Image.Image:
    """Обрезает status/nav bar + делает rounded corners."""
    w, h = shot.size
    # Crop status bar + nav bar
    cropped = shot.crop((0, STATUS_BAR_H, w, h - NAV_BAR_H))
    # Rounded mask
    mask = Image.new("L", cropped.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), cropped.size], radius=radius, fill=255)
    out = Image.new("RGBA", cropped.size, (0, 0, 0, 0))
    out.paste(cropped, (0, 0), mask)
    return out


def wrap_text(text: str, font: ImageFont.FreeTypeFont, max_w: int, draw: ImageDraw.ImageDraw) -> list[str]:
    """Простой wrap по словам."""
    words = text.split()
    lines = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        w = draw.textlength(candidate, font=font)
        if w <= max_w:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def make_mockup(raw_path: Path, lang: str, screen: str, out_path: Path) -> None:
    """Собирает одну конверсионную картинку."""
    shot = Image.open(raw_path).convert("RGBA")
    # Масштабируем под ширину canvas - padding
    device_w = CANVAS_W - 160
    sw, sh = shot.size
    scale = device_w / sw
    shot = shot.resize((int(sw * scale), int(sh * scale)), Image.Resampling.LANCZOS)
    # Обрезаем + rounded
    shot = rounded_shot(shot, radius=56)

    # Canvas
    canvas = draw_gradient_bg().convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    # Заголовок + подзаголовок
    headline, subline = HEADLINES.get(lang, HEADLINES["en"])[screen]
    h_font = find_font(lang, 82)
    s_font = find_font(lang, 44)

    # Wrap headline
    max_text_w = CANVAS_W - 140
    h_lines = wrap_text(headline, h_font, max_text_w, draw)
    s_lines = wrap_text(subline, s_font, max_text_w, draw)

    y = 120
    for line in h_lines:
        w = draw.textlength(line, font=h_font)
        draw.text(((CANVAS_W - w) // 2, y), line, font=h_font, fill=WHITE)
        y += int(h_font.size * 1.15)
    y += 10
    for line in s_lines:
        w = draw.textlength(line, font=s_font)
        draw.text(((CANVAS_W - w) // 2, y), line, font=s_font, fill=(255, 255, 255, 220))
        y += int(s_font.size * 1.25)

    # Тень под скриншот
    shadow_w, shadow_h = shot.size
    shadow = Image.new("RGBA", (shadow_w + 80, shadow_h + 80), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([(20, 40), (shadow_w + 60, shadow_h + 60)], radius=56, fill=SHADOW)
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=30))

    # Позиция скриншота
    shot_x = (CANVAS_W - shot.size[0]) // 2
    shot_y = y + 60
    # Проверка что влезает
    if shot_y + shot.size[1] > CANVAS_H - 40:
        # Подрежем скриншот снизу
        max_h = CANVAS_H - 40 - shot_y
        shot = shot.crop((0, 0, shot.size[0], max_h))

    # Рисуем тень и скриншот
    canvas.alpha_composite(shadow, (shot_x - 40, shot_y - 40))
    canvas.alpha_composite(shot, (shot_x, shot_y))

    canvas.convert("RGB").save(out_path, "PNG", optimize=True)


def main():
    langs = sorted([d.name for d in RAW.iterdir() if d.is_dir()])
    print(f"Found {len(langs)} languages: {langs}")
    for lang in langs:
        out_dir = OUT / lang
        out_dir.mkdir(parents=True, exist_ok=True)
        for screen in ["01_home", "02_add_episode", "03_history", "04_report"]:
            raw = RAW / lang / f"{screen}.png"
            if not raw.exists():
                print(f"  SKIP missing: {raw}")
                continue
            out = out_dir / f"{screen}.png"
            make_mockup(raw, lang, screen, out)
            print(f"  OK: {out}")


if __name__ == "__main__":
    main()
