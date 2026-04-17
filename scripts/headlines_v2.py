"""
VasoLog - Draft v2 conversion-focused headlines.
Все 18 языков × 6 screens × 2 фразы = 216 локализованных фрагментов.

Формула headline: benefit + emotion + Raynaud's-specific.
Формула subhead: features + "only here" / USP.

Localization principles:
- Медицинский регистр: формальный где требуется (DE Sie-form, KO 존댓말)
- Native feel: каждая фраза должна звучать естественно для носителя
- Length: headline 2 lines max, subhead 1 line max
- Cultural: emotional punch без cringe

НУЖЕН NATIVE AUDIT после этого файла!
"""

# Screen IDs:
#   01_home          - overview hook
#   02_add_top       - quick logging (speed)
#   03_add_hands     - USP hand-by-hand (the FOMO screen)
#   04_history       - insights
#   05_add_bottom    - remember every detail
#   06_report        - medical trust (PDF for doctor)

HEADLINES_V2 = {
    "en": {
        "01_home":       ("Your Raynaud's,\ndecoded.",           "Weather, attacks, triggers — one place"),
        "02_add_top":    ("Log an attack in\n10 seconds",        "Severity, color, fingers — at a glance"),
        "03_add_hands":  ("Every finger\ntells a story",         "Tap exactly where — only here"),
        "04_history":    ("Patterns your\ndoctor misses",        "Weekly charts reveal YOUR triggers"),
        "05_add_bottom": ("Never forget\nan attack",             "Photos, notes, full history"),
        "06_report":     ("Your doctor\nwill thank you",         "6-month medical PDF — one tap"),
    },
    "ru": {
        "01_home":       ("Синдром Рейно,\nрасшифрован",         "Погода, приступы, триггеры — в одном месте"),
        "02_add_top":    ("Запиши приступ\nза 10 секунд",        "Тяжесть, цвет, пальцы — с одного взгляда"),
        "03_add_hands":  ("Каждый палец\nрасскажет историю",     "Отметь точно где — только здесь"),
        "04_history":    ("Что врач\nупускает",                  "Недельные графики раскроют твои триггеры"),
        "05_add_bottom": ("Не забудь\nни один приступ",          "Фото, заметки, полная история"),
        "06_report":     ("Твой врач\nскажет спасибо",           "6-месячный мед. PDF — в один тап"),
    },
    "de": {
        "01_home":       ("Raynaud\nverstehen",                  "Wetter, Anfälle, Auslöser — an einem Ort"),
        "02_add_top":    ("Anfall in\n10 Sekunden",              "Schwere, Farbe, Finger — auf einen Blick"),
        "03_add_hands":  ("Jeden Finger\nindividuell erfassen",  "Genau dort tippen — nur hier"),
        "04_history":    ("Muster, die Ärzte\nübersehen",        "Wochengrafiken zeigen Ihre Auslöser"),
        "05_add_bottom": ("Keinen Anfall\nvergessen",            "Fotos, Notizen, volle Historie"),
        "06_report":     ("Ihre Konsultation\nwird präziser",    "6-Monats-PDF — mit einem Tipp"),
    },
    "fr": {
        "01_home":       ("Votre Raynaud,\ndécodé",              "Météo, crises, facteurs — au même endroit"),
        "02_add_top":    ("Une crise en\n10 secondes",           "Gravité, couleur, doigts — d'un coup d'œil"),
        "03_add_hands":  ("Chaque doigt\na son histoire",        "Touchez où ça fait mal — unique ici"),
        "04_history":    ("Schémas que votre\nmédecin manque",   "Graphiques hebdo révèlent VOS facteurs"),
        "05_add_bottom": ("Ne jamais oublier\nune crise",        "Photos, notes, historique complet"),
        "06_report":     ("Votre médecin\nvous remerciera",      "PDF médical 6 mois — en un tap"),
    },
    "es": {
        "01_home":       ("Tu Raynaud,\ndescifrado",             "Clima, crisis, desencadenantes — en un lugar"),
        "02_add_top":    ("Registra una crisis\nen 10 segundos", "Gravedad, color, dedos — al instante"),
        "03_add_hands":  ("Cada dedo\ncuenta su historia",       "Toca exactamente dónde — único aquí"),
        "04_history":    ("Patrones que tu\nmédico no ve",       "Gráficos semanales revelan TUS desencadenantes"),
        "05_add_bottom": ("Nunca olvides\nuna crisis",           "Fotos, notas, historial completo"),
        "06_report":     ("Tu médico\nte lo agradecerá",         "PDF médico de 6 meses — un toque"),
    },
    "pt": {
        "01_home":       ("O seu Raynaud,\ndecifrado",           "Tempo, crises, gatilhos — num só lugar"),
        "02_add_top":    ("Registe uma crise\nem 10 segundos",   "Gravidade, cor, dedos — num instante"),
        "03_add_hands":  ("Cada dedo\nconta uma história",       "Toque exatamente onde — só aqui"),
        "04_history":    ("Padrões que o seu\nmédico não vê",    "Gráficos semanais revelam OS SEUS gatilhos"),
        "05_add_bottom": ("Nunca esqueça\numa crise",            "Fotos, notas, histórico completo"),
        "06_report":     ("O seu médico\nagradecerá",            "PDF médico 6 meses — um toque"),
    },
    "it": {
        "01_home":       ("Il tuo Raynaud,\ndecodificato",       "Meteo, crisi, fattori — in un posto"),
        "02_add_top":    ("Registra una crisi\nin 10 secondi",   "Gravità, colore, dita — all'istante"),
        "03_add_hands":  ("Ogni dito,\nla sua storia",           "Tocca dove fa male — solo qui"),
        "04_history":    ("Schemi che il tuo\nmedico non vede",  "Grafici settimanali rivelano i TUOI fattori"),
        "05_add_bottom": ("Non dimenticare\nuna crisi",          "Foto, note, cronologia completa"),
        "06_report":     ("Il tuo medico\nti ringrazierà",       "PDF medico 6 mesi — un tocco"),
    },
    "sv": {
        "01_home":       ("Ditt Raynaud,\navkodat",              "Väder, anfall, utlösare — på ett ställe"),
        "02_add_top":    ("Logga ett anfall\npå 10 sekunder",    "Svårhet, färg, fingrar — direkt"),
        "03_add_hands":  ("Varje finger\nberättar en historia",  "Tryck exakt där — bara här"),
        "04_history":    ("Mönster din\nläkare missar",          "Veckografer avslöjar DINA utlösare"),
        "05_add_bottom": ("Glöm aldrig\nett anfall",             "Foton, anteckningar, hela historiken"),
        "06_report":     ("Din läkare\nkommer att tacka dig",    "6-månaders PDF — ett tryck"),
    },
    "fi": {
        "01_home":       ("Raynaud,\nselvitetty",                "Sää, kohtaukset, laukaisijat — yhdessä paikassa"),
        "02_add_top":    ("Kirjaa kohtaus\n10 sekunnissa",       "Vakavuus, väri, sormet — heti"),
        "03_add_hands":  ("Jokainen sormi\nkertoo tarinan",      "Napauta tarkasti missä — vain täällä"),
        "04_history":    ("Kaavat, jotka\nlääkäri missaa",       "Viikkokaaviot paljastavat sinun laukaisijasi"),
        "05_add_bottom": ("Älä unohda\nkohtausta",               "Kuvat, muistiinpanot, täysi historia"),
        "06_report":     ("Lääkärisi\nkiittää sinua",            "6 kk PDF — yhdellä napautuksella"),
    },
    "nb": {
        "01_home":       ("Ditt Raynaud,\ndekodet",              "Vær, anfall, utløsere — på ett sted"),
        "02_add_top":    ("Logg et anfall\npå 10 sekunder",      "Alvor, farge, fingre — straks"),
        "03_add_hands":  ("Hver finger\nhar en historie",        "Trykk nøyaktig der — bare her"),
        "04_history":    ("Mønstre legen\ndin overser",          "Ukesgrafer avslører DINE utløsere"),
        "05_add_bottom": ("Aldri glem\net anfall",               "Bilder, notater, full historikk"),
        "06_report":     ("Legen din\nvil takke deg",            "6-måneders PDF — ett trykk"),
    },
    "da": {
        "01_home":       ("Dit Raynaud,\ndekodet",               "Vejr, anfald, udløsere — ét sted"),
        "02_add_top":    ("Log et anfald\npå 10 sekunder",       "Sværhed, farve, fingre — straks"),
        "03_add_hands":  ("Hver finger\nhar en historie",        "Tryk præcist hvor — kun her"),
        "04_history":    ("Mønstre din\nlæge overser",           "Ugegrafer afslører DINE udløsere"),
        "05_add_bottom": ("Glem aldrig\net anfald",              "Fotos, noter, fuld historik"),
        "06_report":     ("Din læge vil\ntakke dig",             "6-måneders PDF — ét tryk"),
    },
    "nl": {
        "01_home":       ("Jouw Raynaud,\ngedecodeerd",          "Weer, aanvallen, triggers — op één plek"),
        "02_add_top":    ("Log een aanval\nin 10 seconden",      "Ernst, kleur, vingers — in één oogopslag"),
        "03_add_hands":  ("Elke vinger\nvertelt een verhaal",    "Tik precies waar — alleen hier"),
        "04_history":    ("Patronen die\nje arts mist",          "Weekgrafieken onthullen JOUW triggers"),
        "05_add_bottom": ("Vergeet nooit\neen aanval",           "Foto's, notities, volledige geschiedenis"),
        "06_report":     ("Je arts zal\nje dankbaar zijn",       "6-maanden medische PDF — één tik"),
    },
    "pl": {
        "01_home":       ("Twój Raynaud,\nrozszyfrowany",        "Pogoda, ataki, wyzwalacze — w jednym miejscu"),
        "02_add_top":    ("Zapisz atak\nw 10 sekund",            "Nasilenie, kolor, palce — od razu"),
        "03_add_hands":  ("Każdy palec\nma swoją historię",      "Dotknij dokładnie gdzie — tylko tutaj"),
        "04_history":    ("Wzorce, które\nlekarz pomija",        "Tygodniowe wykresy ujawniają TWOJE wyzwalacze"),
        "05_add_bottom": ("Nigdy nie zapomnij\nataku",           "Zdjęcia, notatki, pełna historia"),
        "06_report":     ("Twój lekarz\npodziękuje",             "6-miesięczny PDF — jedno dotknięcie"),
    },
    "cs": {
        "01_home":       ("Tvůj Raynaud,\nrozšifrován",          "Počasí, záchvaty, spouštěče — na jednom místě"),
        "02_add_top":    ("Zaznamenej záchvat\nza 10 sekund",    "Závažnost, barva, prsty — okamžitě"),
        "03_add_hands":  ("Každý prst\nmá svůj příběh",          "Klepni přesně kde — jen tady"),
        "04_history":    ("Vzorce, které\nlékař přehlédne",      "Týdenní grafy odhalí tvé spouštěče"),
        "05_add_bottom": ("Nikdy nezapomeň\nzáchvat",            "Fotky, poznámky, plná historie"),
        "06_report":     ("Tvůj lékař\npoděkuje",                "6měsíční PDF — jedním klepnutím"),
    },
    "hu": {
        "01_home":       ("A Raynaud-szindrómád,\ndekódolva",    "Időjárás, rohamok, kiváltók — egy helyen"),
        "02_add_top":    ("Rögzíts rohamot\n10 másodperc alatt", "Súlyosság, szín, ujjak — azonnal"),
        "03_add_hands":  ("Minden ujj\ntörténetet mesél",        "Érintsd pontosan hol — csak itt"),
        "04_history":    ("Minták, amiket az\norvos elnéz",      "Heti grafikonok felfedik a te kiváltóidat"),
        "05_add_bottom": ("Soha ne felejts\nel rohamot",         "Fotók, jegyzetek, teljes előzmény"),
        "06_report":     ("Az orvosod meg\nfogja köszönni",      "6 hónapos PDF — egy érintéssel"),
    },
    "uk": {
        "01_home":       ("Твій Рейно,\nрозшифрований",          "Погода, напади, тригери — в одному місці"),
        "02_add_top":    ("Запиши напад\nза 10 секунд",          "Важкість, колір, пальці — миттєво"),
        "03_add_hands":  ("Кожен палець\nрозповість історію",    "Торкнись точно де — тільки тут"),
        "04_history":    ("Що лікар\nпропускає",                 "Тижневі графіки розкриють твої тригери"),
        "05_add_bottom": ("Не забудь\nжодного нападу",           "Фото, нотатки, повна історія"),
        "06_report":     ("Твій лікар\nподякує",                 "6-місячний PDF — один дотик"),
    },
    "ja": {
        "01_home":       ("レイノー現象を\n完全解読",              "天気・発作・誘因 — 一つに"),
        "02_add_top":    ("発作を10秒で\n記録",                   "重症度・色・指 — 一目で"),
        "03_add_hands":  ("指一本一本に\n物語",                   "痛い場所を正確に — ここだけ"),
        "04_history":    ("医師も気づかない\nパターン",            "週間グラフがあなたの誘因を解明"),
        "05_add_bottom": ("発作を\n忘れない",                     "写真・メモ・全履歴"),
        "06_report":     ("医師から\n感謝されます",                "6ヶ月の医療PDF — ワンタップ"),
    },
    "ko": {
        "01_home":       ("레이노 증후군,\n완벽 해독",             "날씨·발작·유발 요인 — 한 곳에"),
        "02_add_top":    ("발작을 10초\n만에 기록",               "심각도·색상·손가락 — 한눈에"),
        "03_add_hands":  ("모든 손가락의\n이야기",                "아픈 곳을 정확히 — 여기서만"),
        "04_history":    ("의사도 놓치는\n패턴",                  "주간 차트가 당신의 유발 요인 발견"),
        "05_add_bottom": ("발작을\n잊지 않기",                    "사진·메모·전체 기록"),
        "06_report":     ("의사가 신뢰하는\n앱",                  "6개월 의료 PDF — 한 번의 탭"),
    },
}

# USP badges на 03_add_hands - native "UNIQUE"
USP_BADGES = {
    "en": "UNIQUE", "ru": "ТОЛЬКО ЗДЕСЬ", "de": "EINZIGARTIG",
    "fr": "UNIQUE", "es": "ÚNICO", "pt": "ÚNICO",
    "it": "UNICO", "sv": "UNIKT", "fi": "AINUTLAATUINEN",
    "nb": "UNIKT", "da": "UNIKT", "nl": "UNIEK",
    "pl": "UNIKALNE", "cs": "JEDINEČNÉ", "hu": "EGYEDI",
    "uk": "ЛИШЕ ТУТ", "ja": "独自機能", "ko": "독점 기능",
}
