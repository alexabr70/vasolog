"""
VasoLog — AppGallery ASO оптимизация
Апрель 2026

Что делает:
  1. Создаёт title.txt (до 64 chars) — AppGallery даёт 64, App Store даёт 30
     Используем лишние 34 символа для ключевых слов
  2. Создаёт brief_intro.txt (до 80 chars) — hook + 2-3 keywords
     Алгоритм AppGallery индексирует title + description (нет отдельного keywords поля)
  3. Добавляет медицинский дисклеймер в конец description_full.txt
     (обязателен для Health категории по AppGallery guidelines)
  4. Генерирует docs/publishing/appgallery_listing.md — полный листинг для copy-paste

Запуск: py scripts/prepare_appgallery_aso.py
"""

import sys
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

from pathlib import Path

ROOT = Path(__file__).parent.parent
AG_DIR = ROOT / "release" / "v1.1.0" / "metadata" / "_platform_specific" / "appgallery"
DOCS = ROOT / "docs" / "publishing"

# ─────────────────────────────────────────────────────────────────────────────
# ASO данные по языкам
# Принципы:
#   Title    — главный keyword в первых словах, до 64 символов
#   Brief    — hook + USP + benefit, до 80 символов
#              точка · как разделитель (читаемо, не спам)
#   Disclaimer — перевод официального AppGallery health disclaimer
# ─────────────────────────────────────────────────────────────────────────────
LANGS = {
    "en": {
        "title":   "VasoLog: Raynaud Symptom Tracker + Doctor Reports",
        "brief":   "Log Raynaud's episodes · Auto weather · Trigger insights · PDF for your doctor",
        "disclaimer": (
            "DISCLAIMER: VasoLog is a personal symptom diary and is NOT a medical device. "
            "It does not diagnose, treat, cure, or prevent any medical condition. "
            "Please consult a qualified healthcare professional for medical advice."
        ),
    },
    "ru": {
        "title":   "VasoLog: дневник Рейно + PDF-отчёты для врача",
        "brief":   "Дневник Рейно: приступы, погода, триггеры — PDF-отчёт для ревматолога",
        "disclaimer": (
            "ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: VasoLog — личный дневник симптомов и НЕ является "
            "медицинским устройством. Приложение не диагностирует, не лечит и не заменяет "
            "профессиональную медицинскую помощь. Проконсультируйтесь с врачом."
        ),
    },
    "de": {
        "title":   "VasoLog: Raynaud Symptom-Tracker + Arztberichte",
        "brief":   "Raynaud-Anfälle dokumentieren · Wetter · Trigger · PDF-Bericht für den Arzt",
        "disclaimer": (
            "HAFTUNGSAUSSCHLUSS: VasoLog ist ein persönliches Symptomtagebuch und KEIN "
            "Medizinprodukt. Die App stellt keine Diagnose, behandelt keine Erkrankungen und "
            "ersetzt keine professionelle medizinische Beratung. Bitte konsultieren Sie einen Arzt."
        ),
    },
    "fr": {
        "title":   "VasoLog: Suivi Raynaud + Rapports PDF pour médecin",
        "brief":   "Crises Raynaud · météo auto · déclencheurs · rapport PDF pour votre médecin",
        "disclaimer": (
            "AVERTISSEMENT: VasoLog est un journal personnel de symptômes et N'EST PAS un "
            "dispositif médical. Il ne diagnostique, ne traite ni ne remplace les conseils "
            "médicaux professionnels. Consultez un professionnel de santé qualifié."
        ),
    },
    "ja": {
        "title":   "VasoLog: レイノー症状記録アプリ＋医師レポート",
        "brief":   "レイノー発作記録・自動天気・誘因分析・医師向けPDFレポート",
        "disclaimer": None,  # уже есть
    },
    "it": {
        "title":   "VasoLog: Monitor Raynaud + Referti Medici PDF",
        "brief":   "Episodi Raynaud · meteo auto · trigger · report PDF per il tuo medico",
        "disclaimer": (
            "DISCLAIMER: VasoLog è un diario personale dei sintomi e NON è un dispositivo "
            "medico. Non diagnostica, non tratta e non sostituisce la consulenza medica "
            "professionale. Consulta un operatore sanitario qualificato."
        ),
    },
    "es": {
        "title":   "VasoLog: Tracker Raynaud + Informes para Médico",
        "brief":   "Crisis Raynaud · clima auto · desencadenantes · informe PDF para médico",
        "disclaimer": (
            "AVISO: VasoLog es un diario personal de síntomas y NO es un dispositivo médico. "
            "No diagnostica, no trata ni reemplaza el consejo médico profesional. "
            "Consulte a un profesional de salud calificado."
        ),
    },
    "pt-br": {
        "title":   "VasoLog: Monitor Raynaud + Relatórios para Médico",
        "brief":   "Crises Raynaud · clima auto · gatilhos · relatório PDF para seu médico",
        "disclaimer": (
            "AVISO: VasoLog é um diário pessoal de sintomas e NÃO é um dispositivo médico. "
            "Não diagnostica, não trata nem substitui o aconselhamento médico profissional. "
            "Consulte um profissional de saúde qualificado."
        ),
    },
    "pt": {
        "title":   "VasoLog: Monitor Raynaud + Relatórios Médicos PDF",
        "brief":   "Crises Raynaud · meteorologia auto · gatilhos · relatório PDF para médico",
        "disclaimer": (
            "AVISO: VasoLog é um diário pessoal de sintomas e NÃO é um dispositivo médico. "
            "Não diagnostica, não trata nem substitui o aconselhamento médico profissional. "
            "Consulte um profissional de saúde qualificado."
        ),
    },
    "nl": {
        "title":   "VasoLog: Raynaud Tracker + Medische PDF-rapporten",
        "brief":   "Raynaud-aanvallen · auto weer · triggers · PDF-rapport voor uw arts",
        "disclaimer": (
            "DISCLAIMER: VasoLog is een persoonlijk symptoomdagboek en is GEEN medisch "
            "hulpmiddel. Het diagnosticeert, behandelt of vervangt geen professioneel medisch "
            "advies. Raadpleeg een gekwalificeerde zorgverlener."
        ),
    },
    "sv": {
        "title":   "VasoLog: Raynaud Tracker + Läkarrapporter PDF",
        "brief":   "Raynaud-attacker · automatisk väder · triggers · PDF-rapport till läkare",
        "disclaimer": (
            "ANSVARSFRISKRIVNING: VasoLog är en personlig symtomdagbok och är INTE ett "
            "medicintekniskt hjälpmedel. Den diagnostiserar, behandlar eller ersätter inte "
            "professionell medicinsk rådgivning. Konsultera en kvalificerad vårdgivare."
        ),
    },
    "tr": {
        "title":   "VasoLog: Raynaud Takip + Doktor PDF Raporları",
        "brief":   "Raynaud takibi · otomatik hava · tetikleyiciler · doktor PDF raporu",
        "disclaimer": (
            "SORUMLULUK REDDI: VasoLog kisisel bir semptom gunlugudur ve tibbi bir cihaz "
            "DEGILDIR. Teshis koymaz, tedavi etmez ve profesyonel tibbi tavsiyenin yerini "
            "tutmaz. Nitelikli bir saglik uzmanina danisin."
        ),
    },
    "pl": {
        "title":   "VasoLog: Tracker Raynauda + Raporty dla Lekarza",
        "brief":   "Ataki Raynauda · auto pogoda · czynniki wyzwalajace · raport PDF lekarski",
        "disclaimer": (
            "ZASTRZEZENIE: VasoLog to osobisty dziennik objawow i NIE jest urzadzeniem "
            "medycznym. Nie diagnozuje, nie leczy i nie zastepuje profesjonalnej porady "
            "medycznej. Skonsultuj sie z wykwalifikowanym specjalista."
        ),
    },
}

# ─────────────────────────────────────────────────────────────────────────────

def validate(lang: str, key: str, value: str, limit: int):
    n = len(value)
    status = "OK" if n <= limit else f"OVER by {n - limit}"
    print(f"  [{status:12}] {lang}/{key}: {n}/{limit} chars")
    if n > limit:
        raise ValueError(f"{lang}/{key}: {n} chars > {limit} limit")


def write_if_changed(path: Path, content: str) -> bool:
    path.parent.mkdir(parents=True, exist_ok=True)
    existing = path.read_text(encoding="utf-8") if path.exists() else None
    if existing == content:
        return False
    path.write_text(content, encoding="utf-8")
    return True


def add_disclaimer_if_missing(lang: str, disclaimer: str):
    path = AG_DIR / lang / "description_full.txt"
    if not path.exists():
        print(f"  [SKIP] {lang}/description_full.txt not found")
        return
    text = path.read_text(encoding="utf-8")
    # Проверяем несколько вариантов написания
    markers = ["DISCLAIMER", "HAFTUNGSAUSSCHLUSS", "AVERTISSEMENT",
               "AVISO", "ZASTRZEZ", "ANSVARSFRISK", "SORUMLULUK",
               "OTKAZOT", "OTKAS", "DISCLAIMER:", "---\n"]
    already = any(m in text for m in markers)
    if already:
        print(f"  [SKIP] {lang} — дисклеймер уже есть")
        return
    new_text = text.rstrip() + "\n---\n" + disclaimer + "\n"
    path.write_text(new_text, encoding="utf-8")
    print(f"  [+] {lang} — дисклеймер добавлен")


def generate_listing_doc():
    lines = [
        "# AppGallery Connect — Полный листинг VasoLog v1.1.0",
        "",
        "> Готово к copy-paste в AppGallery Connect UI.",
        "> Все тексты ASO-оптимизированы: ключевые слова в title + first 167 chars description.",
        "",
        "## Технические данные (одинаковые для всех языков)",
        "",
        "| Параметр | Значение |",
        "|----------|---------|",
        "| Package Name | `com.vasolog.app` |",
        "| Version | 1.1.0 (versionCode 2) |",
        "| APK | `release/v1.1.0/vasolog-v1.1.0-appgallery.apk` |",
        "| Category | Health & Fitness |",
        "| Age Rating | **7+** |",
        "| Privacy Policy | `https://alexabr70.github.io/vasolog/privacy_policy.html` |",
        "| Contact Email | `vasolog.app@gmail.com` |",
        "| Icon (216×216) | `release/v1.1.0/store_assets/icons/appgallery_216x216.png` |",
        "| Screenshots | `release/v1.1.0/store_assets/screenshots/appgallery/` (5 шт.) |",
        "",
        "### Certificate Fingerprint (SHA-256)",
        "```",
        "9F:9E:55:0B:41:87:4A:B0:C8:84:05:0D:94:2E:47:02:E9:57:D0:6C:D0:A8:11:CF:46:B0:97:B5:CE:CE:B1:4E",
        "```",
        "",
        "---",
        "",
        "## Листинг по языкам",
        "",
    ]

    for lang, data in LANGS.items():
        # Читаем описание из файла
        desc_path = AG_DIR / lang / "description_full.txt"
        desc = desc_path.read_text(encoding="utf-8").strip() if desc_path.exists() else "(missing)"

        lines += [
            f"### {lang.upper()}",
            "",
            f"**App Name (≤64):** `{data['title']}`",
            f"> {len(data['title'])} символов",
            "",
            f"**Brief Introduction (≤80):** `{data['brief']}`",
            f"> {len(data['brief'])} символов",
            "",
            "**Detailed Introduction:**",
            "```",
            desc,
            "```",
            "",
            "---",
            "",
        ]

    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────────────────────

def main():
    print("\n=== AppGallery ASO ===\n")
    errors = []

    # 1. title.txt + brief_intro.txt
    print("[ 1/3 ] Создаю title.txt + brief_intro.txt")
    for lang, data in LANGS.items():
        try:
            validate(lang, "title",       data["title"], 64)
            validate(lang, "brief_intro", data["brief"], 80)
        except ValueError as e:
            errors.append(str(e))
            continue

        changed_t = write_if_changed(AG_DIR / lang / "title.txt",       data["title"] + "\n")
        changed_b = write_if_changed(AG_DIR / lang / "brief_intro.txt", data["brief"] + "\n")
        if not changed_t and not changed_b:
            print(f"  [=] {lang} — без изменений")

    # 2. Дисклеймеры
    print("\n[ 2/3 ] Дисклеймеры в description_full.txt")
    for lang, data in LANGS.items():
        if data["disclaimer"] is None:
            print(f"  [SKIP] {lang} — нет нужды (уже есть)")
            continue
        add_disclaimer_if_missing(lang, data["disclaimer"])

    # 3. Документ листинга
    print("\n[ 3/3 ] Генерирую docs/publishing/appgallery_listing.md")
    listing = generate_listing_doc()
    dst = DOCS / "appgallery_listing.md"
    dst.write_text(listing, encoding="utf-8")
    print(f"  + {dst.relative_to(ROOT)}  ({len(listing)} chars)")

    if errors:
        print(f"\nОШИБКИ: {errors}")
        sys.exit(1)

    print("\n=== Готово ===")
    print("""
Файлы созданы в _platform_specific/appgallery/{lang}/:
  title.txt       — AppGallery App Name (до 64 chars, с keywords)
  brief_intro.txt — Brief Introduction (до 80 chars, ASO hook)
  description_full.txt — обновлён дисклеймер (если отсутствовал)

docs/publishing/appgallery_listing.md — полный листинг для copy-paste
""")


if __name__ == "__main__":
    main()
