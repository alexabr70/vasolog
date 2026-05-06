"""
VasoLog - v3 conversion-focused headlines.
Все 18 языков × 6 screens × 2 фразы = 216 локализованных фрагментов.

Изменения от v2 (на основе native speaker аудита + competitive research):

1. Strategic positioning - VasoLog единственный публичный Raynaud-tracker в Google Play.
   Используем главный локализованный мед.ключ из real search audit (Mayo Clinic,
   Terveyskirjasto.fi, MedicalNote, Thuisarts.nl и т.д.) в screen 01 для конверсии.

2. Native speaker fixes (P1 - грамматика/диалект):
   - pt: "Registe" -> "Registre" (pt-BR форма)
   - fr: "Schémas que votre médecin manque" (грамматика) -> "Ce que votre médecin ne voit pas"
   - fr: "Touchez où ça fait mal" (разговорно) -> "Indiquez précisément où"
   - ko: "독점 기능" (монополия) -> "고유 기능" (уникальный)
   - fi: "missaa" (англицизм) -> "jättää huomaamatta"

3. Native speaker fixes (P2 - стилистика):
   - sv/da/nb: добавлен подчинительный союз "som"
   - it: "Tocca dove fa male" -> "Indica esattamente dove"
   - ja: "物語" -> "違う症状" (медицинский регистр)
   - ko: "이야기" -> "신호"
   - ja screen 06: "感謝されます" -> "喜ばれます" (теплый тон)
   - ko screen 05: "잊지 않기" (detached infinitive) -> "놓치지 마세요"
   - hu: добавлен артикль "a" / "egy ... sem" / "elnéz" -> "sem vesz észre"
   - nl: "Log" -> "Registreer" (более формально)
   - fr screen 02: добавлен глагол "Enregistrez"
   - uk: "напад" -> "криза" (нейтральнее в укр.мед.литературе)

4. RCS medical credibility (screen 04):
   Заменили "patterns doctor misses" на упоминание RCS scale - стандарт клинических
   исследований Raynaud's. Повышает trust для пациентов с диагнозом.

5. Primary keyword sync (real search audit):
   - en: Raynaud's disease (Mayo Clinic)
   - es: síndrome de Raynaud (teknon.es H1)
   - pt: fenômeno de Raynaud (SciELO)
   - ja: レイノー現象 (MedicalNote H1)
   - nl: fenomeen van Raynaud (Thuisarts.nl)
   - fi: valkosormisuus (Terveyskirjasto.fi - финский народный термин)
   - ko: 레이노 현상 (медицинский) + 수족냉증 (народный)
   - nb: Raynauds fenomen (Oslo Univ. Sykehus)
"""

# Screen IDs:
#   01_home          - strategic positioning + primary keyword
#   02_add_top       - quick logging (speed benefit)
#   03_add_hands     - USP hand-by-hand (FOMO + unique)
#   04_history       - RCS medical credibility
#   05_add_bottom    - never forget
#   06_report        - PDF for doctor

HEADLINES_V2 = {
    "en": {
        "01_home":       ("Raynaud's disease,\ndecoded.",          "Built for Raynaud's. Only Raynaud's."),
        "02_add_top":    ("Log an attack in\n10 seconds",          "Severity, color, fingers — at a glance"),
        "03_add_hands":  ("Every finger\ntells a story",           "Tap exactly where — only here"),
        "04_history":    ("Track the way\ndoctors do",             "RCS scale used in clinical trials"),
        "05_add_bottom": ("Never forget\nan attack",               "Photos, notes, full history"),
        "06_report":     ("Your doctor\nwill thank you",           "6-month medical PDF — one tap"),
    },
    "ru": {
        "01_home":       ("Синдром Рейно,\nрасшифрован",           "Создано для Рейно. Только Рейно."),
        "02_add_top":    ("Запиши приступ\nза 10 секунд",          "Тяжесть, цвет, пальцы — с одного взгляда"),
        "03_add_hands":  ("Каждый палец\nрасскажет историю",       "Отметь точно где — только здесь"),
        "04_history":    ("Оценивай как\nоценивают врачи",         "Шкала RCS из клинических исследований"),
        "05_add_bottom": ("Не забудь\nни один приступ",            "Фото, заметки, полная история"),
        "06_report":     ("Твой врач\nскажет спасибо",             "6-месячный мед. PDF — в один тап"),
    },
    "de": {
        "01_home":       ("Raynaud-Syndrom\nverstehen",            "Nur für Raynaud. Sonst nichts."),
        "02_add_top":    ("Anfall in\n10 Sekunden erfassen",       "Schwere, Farbe, Finger — auf einen Blick"),
        "03_add_hands":  ("Jeden Finger\nindividuell erfassen",    "Genau dort tippen — nur hier"),
        "04_history":    ("So messen,\nwie Ärzte messen",          "RCS-Skala aus klinischen Studien"),
        "05_add_bottom": ("Keinen Anfall\nvergessen",              "Fotos, Notizen, volle Historie"),
        "06_report":     ("Ihre Konsultation\nwird präziser",      "6-Monats-PDF — mit einem Tipp"),
    },
    "fr": {
        "01_home":       ("Phénomène de Raynaud,\ndécodé",         "Conçu pour Raynaud. Uniquement."),
        "02_add_top":    ("Enregistrez une crise\nen 10 secondes", "Gravité, couleur, doigts — d'un coup d'œil"),
        "03_add_hands":  ("Chaque doigt\na son histoire",          "Indiquez précisément où — unique ici"),
        "04_history":    ("Évaluez comme\nles médecins",           "Échelle RCS des essais cliniques"),
        "05_add_bottom": ("Ne jamais oublier\nune crise",          "Photos, notes, historique complet"),
        "06_report":     ("Votre médecin\nvous remerciera",        "PDF médical 6 mois — en un tap"),
    },
    "es": {
        "01_home":       ("Síndrome de Raynaud,\ndescifrado",      "Creado para Raynaud. Solo Raynaud."),
        "02_add_top":    ("Registra una crisis\nen 10 segundos",   "Gravedad, color, dedos — al instante"),
        "03_add_hands":  ("Cada dedo\ncuenta su historia",         "Toca exactamente dónde — único aquí"),
        "04_history":    ("Mide como\nlos médicos",                "Escala RCS de ensayos clínicos"),
        "05_add_bottom": ("Nunca olvides\nuna crisis",             "Fotos, notas, historial completo"),
        "06_report":     ("Tu médico\nte lo agradecerá",           "PDF médico de 6 meses — un toque"),
    },
    "pt": {
        "01_home":       ("Fenômeno de Raynaud,\ndecifrado",       "Criado para Raynaud. Só Raynaud."),
        "02_add_top":    ("Registre uma crise\nem 10 segundos",    "Gravidade, cor, dedos — num instante"),
        "03_add_hands":  ("Cada dedo\nconta uma história",         "Toque exatamente onde — só aqui"),
        "04_history":    ("Meça como\nos médicos",                 "Escala RCS de ensaios clínicos"),
        "05_add_bottom": ("Nunca esqueça\numa crise",              "Fotos, notas, histórico completo"),
        "06_report":     ("Seu médico\nagradecerá",                "PDF médico 6 meses — um toque"),
    },
    "it": {
        "01_home":       ("Sindrome di Raynaud,\ndecodificata",    "Creato per Raynaud. Solo Raynaud."),
        "02_add_top":    ("Registra una crisi\nin 10 secondi",     "Gravità, colore, dita — all'istante"),
        "03_add_hands":  ("Ogni dito,\nla sua storia",             "Indica esattamente dove — solo qui"),
        "04_history":    ("Misura come\ni medici",                 "Scala RCS degli studi clinici"),
        "05_add_bottom": ("Non dimenticare\nuna crisi",            "Foto, note, cronologia completa"),
        "06_report":     ("Il tuo medico\nti ringrazierà",         "PDF medico 6 mesi — un tocco"),
    },
    "sv": {
        "01_home":       ("Raynauds syndrom,\navkodat",            "Skapad för Raynaud. Bara Raynaud."),
        "02_add_top":    ("Logga ett anfall\npå 10 sekunder",      "Svårhet, färg, fingrar — direkt"),
        "03_add_hands":  ("Varje finger\nberättar en historia",    "Tryck exakt där — bara här"),
        "04_history":    ("Mät som\nläkarna mäter",                "RCS-skalan från kliniska studier"),
        "05_add_bottom": ("Glöm aldrig\nett anfall",               "Foton, anteckningar, hela historiken"),
        "06_report":     ("Din läkare\nkommer att tacka dig",      "6-månaders PDF — ett tryck"),
    },
    "fi": {
        "01_home":       ("Valkosormisuus,\nselvitetty",           "Vain Raynaud'n hoitoon. Ei muuhun."),
        "02_add_top":    ("Kirjaa kohtaus\n10 sekunnissa",         "Vakavuus, väri, sormet — heti"),
        "03_add_hands":  ("Jokainen sormi\nkertoo tarinan",        "Napauta tarkasti missä — vain täällä"),
        "04_history":    ("Mittaa kuten\nlääkärit",                "Kliinisten tutkimusten RCS-asteikko"),
        "05_add_bottom": ("Älä unohda\nkohtausta",                 "Kuvat, muistiinpanot, täysi historia"),
        "06_report":     ("Lääkärisi\nkiittää sinua",              "6 kk PDF — yhdellä napautuksella"),
    },
    "nb": {
        "01_home":       ("Raynauds fenomen,\ndekodet",            "Laget for Raynaud. Kun Raynaud."),
        "02_add_top":    ("Logg et anfall\npå 10 sekunder",        "Alvor, farge, fingre — straks"),
        "03_add_hands":  ("Hver finger\nhar en historie",          "Trykk nøyaktig der — bare her"),
        "04_history":    ("Mål slik\nlegene måler",                "RCS-skalaen fra kliniske studier"),
        "05_add_bottom": ("Aldri glem\net anfall",                 "Bilder, notater, full historikk"),
        "06_report":     ("Legen din\nvil takke deg",              "6-måneders PDF — ett trykk"),
    },
    "da": {
        "01_home":       ("Raynauds syndrom,\ndekodet",            "Lavet til Raynaud. Kun Raynaud."),
        "02_add_top":    ("Log et anfald\npå 10 sekunder",         "Sværhed, farve, fingre — straks"),
        "03_add_hands":  ("Hver finger\nhar en historie",          "Tryk præcist hvor — kun her"),
        "04_history":    ("Mål som\nlægerne måler",                "RCS-skalaen fra kliniske studier"),
        "05_add_bottom": ("Glem aldrig\net anfald",                "Fotos, noter, fuld historik"),
        "06_report":     ("Din læge vil\ntakke dig",               "6-måneders PDF — ét tryk"),
    },
    "nl": {
        "01_home":       ("Fenomeen van Raynaud,\ngedecodeerd",    "Gemaakt voor Raynaud. Alleen Raynaud."),
        "02_add_top":    ("Registreer een aanval\nin 10 seconden", "Ernst, kleur, vingers — in één oogopslag"),
        "03_add_hands":  ("Elke vinger\nvertelt een verhaal",      "Tik precies waar — alleen hier"),
        "04_history":    ("Meet zoals\nartsen meten",              "RCS-schaal uit klinische studies"),
        "05_add_bottom": ("Vergeet nooit\neen aanval",             "Foto's, notities, volledige geschiedenis"),
        "06_report":     ("Je arts zal\nje dankbaar zijn",         "6-maanden medische PDF — één tik"),
    },
    "pl": {
        "01_home":       ("Zespół Raynauda,\nrozszyfrowany",       "Stworzone dla Raynauda. Tylko."),
        "02_add_top":    ("Zapisz atak\nw 10 sekund",              "Nasilenie, kolor, palce — od razu"),
        "03_add_hands":  ("Każdy palec\nma swoją historię",        "Dotknij dokładnie gdzie — tylko tutaj"),
        "04_history":    ("Mierz tak,\njak lekarze",               "Skala RCS z badań klinicznych"),
        "05_add_bottom": ("Nigdy nie zapomnij\nataku",             "Zdjęcia, notatki, pełna historia"),
        "06_report":     ("Twój lekarz\npodziękuje",               "6-miesięczny PDF — jedno dotknięcie"),
    },
    "cs": {
        "01_home":       ("Raynaudův syndrom,\nrozšifrován",       "Vytvořeno pro Raynauda. Pouze."),
        "02_add_top":    ("Zaznamenej záchvat\nza 10 sekund",      "Závažnost, barva, prsty — okamžitě"),
        "03_add_hands":  ("Každý prst\nmá svůj příběh",            "Klepni přesně kde — jen tady"),
        "04_history":    ("Měř tak,\njak lékaři",                  "Stupnice RCS z klinických studií"),
        "05_add_bottom": ("Nikdy nezapomeň\nzáchvat",              "Fotky, poznámky, plná historie"),
        "06_report":     ("Tvůj lékař\npoděkuje",                  "6měsíční PDF — jedním klepnutím"),
    },
    "hu": {
        "01_home":       ("Raynaud-szindróma,\ndekódolva",         "Csak Raynaudra. Másra nem."),
        "02_add_top":    ("Rögzítsd a rohamot\n10 másodperc alatt", "Súlyosság, szín, ujjak — azonnal"),
        "03_add_hands":  ("Minden ujj\ntörténetet mesél",          "Érintsd pontosan hol — csak itt"),
        "04_history":    ("Mérd, ahogy\nazt orvosok",              "Klinikai vizsgálatok RCS-skálája"),
        "05_add_bottom": ("Soha ne felejts\nel egy rohamot sem",   "Fotók, jegyzetek, teljes előzmény"),
        "06_report":     ("Az orvosod meg\nfogja köszönni",        "6 hónapos PDF — egy érintéssel"),
    },
    "uk": {
        "01_home":       ("Синдром Рейно,\nрозшифрований",         "Створено для Рейно. Тільки."),
        "02_add_top":    ("Запиши кризу\nза 10 секунд",            "Важкість, колір, пальці — миттєво"),
        "03_add_hands":  ("Кожен палець\nрозповість історію",      "Торкнись точно де — тільки тут"),
        "04_history":    ("Оцінюй як\nоцінюють лікарі",            "Шкала RCS з клінічних досліджень"),
        "05_add_bottom": ("Не забудь\nжодної кризи",               "Фото, нотатки, повна історія"),
        "06_report":     ("Твій лікар\nподякує",                   "6-місячний PDF — один дотик"),
    },
    "ja": {
        "01_home":       ("レイノー現象を\n完全解読",                "レイノー専用アプリ"),
        "02_add_top":    ("発作を10秒で\n記録",                     "重症度・色・指 — 一目で"),
        "03_add_hands":  ("指ごとに\n違う症状",                     "痛い場所を正確に — ここだけ"),
        "04_history":    ("医師と同じ\n方法で記録",                 "臨床試験のRCSスケール"),
        "05_add_bottom": ("発作を\n忘れない",                       "写真・メモ・全履歴"),
        "06_report":     ("先生に\n喜ばれます",                     "6ヶ月の医療PDF — ワンタップ"),
    },
    "ko": {
        "01_home":       ("레이노 현상,\n완벽 해독",                "오직 레이노만을 위해"),
        "02_add_top":    ("발작을 10초\n만에 기록",                 "심각도·색상·손가락 — 한눈에"),
        "03_add_hands":  ("손가락마다의\n신호",                     "아픈 곳을 정확히 — 여기서만"),
        "04_history":    ("의사처럼\n측정하세요",                   "임상 시험의 RCS 척도"),
        "05_add_bottom": ("발작을\n놓치지 마세요",                  "사진·메모·전체 기록"),
        "06_report":     ("의사가 신뢰하는\n앱",                    "6개월 의료 PDF — 한 번의 탭"),
    },
}

# USP badges на 03_add_hands - native "UNIQUE"
# ko: "독점 기능" (монополия) -> "고유 기능" (уникальный)
USP_BADGES = {
    "en": "UNIQUE", "ru": "ТОЛЬКО ЗДЕСЬ", "de": "EINZIGARTIG",
    "fr": "UNIQUE", "es": "ÚNICO", "pt": "ÚNICO",
    "it": "UNICO", "sv": "UNIKT", "fi": "AINUTLAATUINEN",
    "nb": "UNIKT", "da": "UNIKT", "nl": "UNIEK",
    "pl": "UNIKALNE", "cs": "JEDINEČNÉ", "hu": "EGYEDI",
    "uk": "ЛИШЕ ТУТ", "ja": "独自機能", "ko": "고유 기능",
}
