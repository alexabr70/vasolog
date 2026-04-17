/// Локализация VasoLog
/// 18 языков: EN, RU, DE, FR, ES, PT, IT, SV, FI, NB, DA, NL, PL, CS, HU, UK, JA, KO
/// Определяется автоматически по системной локали устройства
class S {
  S._(this.locale);
  static late S current;

  final String locale;

  static void init(String languageCode) {
    current = S._(languageCode);
  }

  // Определение языка
  String get _lang {
    if (locale.startsWith('ru')) return 'ru';
    if (locale.startsWith('de')) return 'de';
    if (locale.startsWith('fr')) return 'fr';
    if (locale.startsWith('es')) return 'es';
    if (locale.startsWith('pt')) return 'pt';
    if (locale.startsWith('it')) return 'it';
    if (locale.startsWith('sv')) return 'sv';
    if (locale.startsWith('fi')) return 'fi';
    if (locale.startsWith('nb') || locale.startsWith('no')) return 'nb';
    if (locale.startsWith('da')) return 'da';
    if (locale.startsWith('nl')) return 'nl';
    if (locale.startsWith('pl')) return 'pl';
    if (locale.startsWith('cs')) return 'cs';
    if (locale.startsWith('hu')) return 'hu';
    if (locale.startsWith('uk')) return 'uk';
    if (locale.startsWith('ja')) return 'ja';
    if (locale.startsWith('ko')) return 'ko';
    return 'en';
  }

  /// Выбор перевода по языку
  String _t(Map<String, String> m) => m[_lang] ?? m['en']!;

  // === Общие ===
  String get appName => 'VasoLog';
  String get save => _t({
    'en': 'Save',
    'ru': 'Сохранить',
    'de': 'Speichern',
    'fr': 'Enregistrer',
    'es': 'Guardar',
    'pt': 'Salvar',
    'it': 'Salva',
    'sv': 'Spara',
    'fi': 'Tallenna',
    'nb': 'Lagre',
    'da': 'Gem',
    'nl': 'Opslaan',
    'pl': 'Zapisz',
    'cs': 'Uložit',
    'hu': 'Mentés',
    'uk': 'Зберегти',
    'ja': '保存',
    'ko': '저장',
  });
  String get cancel => _t({
    'en': 'Cancel',
    'ru': 'Отмена',
    'de': 'Abbrechen',
    'fr': 'Annuler',
    'es': 'Cancelar',
    'pt': 'Cancelar',
    'it': 'Annulla',
    'sv': 'Avbryt',
    'fi': 'Peruuta',
    'nb': 'Avbryt',
    'da': 'Annuller',
    'nl': 'Annuleren',
    'pl': 'Anuluj',
    'cs': 'Zrušit',
    'hu': 'Mégse',
    'uk': 'Скасувати',
    'ja': 'キャンセル',
    'ko': '취소',
  });
  String get delete => _t({
    'en': 'Delete',
    'ru': 'Удалить',
    'de': 'Löschen',
    'fr': 'Supprimer',
    'es': 'Eliminar',
    'pt': 'Excluir',
    'it': 'Elimina',
    'sv': 'Radera',
    'fi': 'Poista',
    'nb': 'Slett',
    'da': 'Slet',
    'nl': 'Verwijderen',
    'pl': 'Usuń',
    'cs': 'Smazat',
    'hu': 'Törlés',
    'uk': 'Видалити',
    'ja': '削除',
    'ko': '삭제',
  });
  String get skip => _t({
    'en': 'Skip',
    'ru': 'Пропустить',
    'de': 'Überspringen',
    'fr': 'Passer',
    'es': 'Omitir',
    'pt': 'Pular',
    'it': 'Salta',
    'sv': 'Hoppa över',
    'fi': 'Ohita',
    'nb': 'Hopp over',
    'da': 'Spring over',
    'nl': 'Overslaan',
    'pl': 'Pomiń',
    'cs': 'Přeskočit',
    'hu': 'Kihagyás',
    'uk': 'Пропустити',
    'ja': 'スキップ',
    'ko': '건너뛰기',
  });
  String get next => _t({
    'en': 'Next',
    'ru': 'Далее',
    'de': 'Weiter',
    'fr': 'Suivant',
    'es': 'Siguiente',
    'pt': 'Próximo',
    'it': 'Avanti',
    'sv': 'Nästa',
    'fi': 'Seuraava',
    'nb': 'Neste',
    'da': 'Næste',
    'nl': 'Volgende',
    'pl': 'Dalej',
    'cs': 'Další',
    'hu': 'Tovább',
    'uk': 'Далі',
    'ja': '次へ',
    'ko': '다음',
  });
  String get notNow => _t({
    'en': 'Not now',
    'ru': 'Не сейчас',
    'de': 'Nicht jetzt',
    'fr': 'Pas maintenant',
    'es': 'Ahora no',
    'pt': 'Agora não',
    'it': 'Non ora',
    'sv': 'Inte nu',
    'fi': 'Ei nyt',
    'nb': 'Ikke nå',
    'da': 'Ikke nu',
    'nl': 'Niet nu',
    'pl': 'Nie teraz',
    'cs': 'Teď ne',
    'hu': 'Most nem',
    'uk': 'Не зараз',
    'ja': '今はしない',
    'ko': '나중에',
  });

  // === Навигация ===
  String get tabHome => _t({
    'en': 'Home',
    'ru': 'Главная',
    'de': 'Start',
    'fr': 'Accueil',
    'es': 'Inicio',
    'pt': 'Início',
    'it': 'Home',
    'sv': 'Hem',
    'fi': 'Koti',
    'nb': 'Hjem',
    'da': 'Hjem',
    'nl': 'Home',
    'pl': 'Główna',
    'cs': 'Domů',
    'hu': 'Kezdőlap',
    'uk': 'Головна',
    'ja': 'ホーム',
    'ko': '홈',
  });
  String get tabHistory => _t({
    'en': 'History',
    'ru': 'История',
    'de': 'Verlauf',
    'fr': 'Historique',
    'es': 'Historial',
    'pt': 'Histórico',
    'it': 'Cronologia',
    'sv': 'Historik',
    'fi': 'Historia',
    'nb': 'Historikk',
    'da': 'Historik',
    'nl': 'Geschiedenis',
    'pl': 'Historia',
    'cs': 'Historie',
    'hu': 'Előzmények',
    'uk': 'Історія',
    'ja': '履歴',
    'ko': '기록',
  });
  String get tabReport => _t({
    'en': 'Report',
    'ru': 'Отчёт',
    'de': 'Bericht',
    'fr': 'Rapport',
    'es': 'Informe',
    'pt': 'Relatório',
    'it': 'Report',
    'sv': 'Rapport',
    'fi': 'Raportti',
    'nb': 'Rapport',
    'da': 'Rapport',
    'nl': 'Rapport',
    'pl': 'Raport',
    'cs': 'Zpráva',
    'hu': 'Jelentés',
    'uk': 'Звіт',
    'ja': 'レポート',
    'ko': '보고서',
  });
  String get tabInfo => _t({
    'en': 'Info',
    'ru': 'Инфо',
    'de': 'Info',
    'fr': 'Info',
    'es': 'Info',
    'pt': 'Info',
    'it': 'Info',
    'sv': 'Info',
    'fi': 'Tiedot',
    'nb': 'Info',
    'da': 'Info',
    'nl': 'Info',
    'pl': 'Info',
    'cs': 'Info',
    'hu': 'Infó',
    'uk': 'Інфо',
    'ja': '情報',
    'ko': '정보',
  });

  // === Главный экран ===
  String get statsTotal => _t({
    'en': 'Total',
    'ru': 'Всего',
    'de': 'Gesamt',
    'fr': 'Total',
    'es': 'Total',
    'pt': 'Total',
    'it': 'Totale',
    'sv': 'Totalt',
    'fi': 'Yhteensä',
    'nb': 'Totalt',
    'da': 'Total',
    'nl': 'Totaal',
    'pl': 'Razem',
    'cs': 'Celkem',
    'hu': 'Összesen',
    'uk': 'Всього',
    'ja': '合計',
    'ko': '전체',
  });
  String get statsWeek => _t({
    'en': 'This week',
    'ru': 'За неделю',
    'de': 'Diese Woche',
    'fr': 'Cette semaine',
    'es': 'Esta semana',
    'pt': 'Esta semana',
    'it': 'Questa settimana',
    'sv': 'Denna vecka',
    'fi': 'Tällä viikolla',
    'nb': 'Denne uken',
    'da': 'Denne uge',
    'nl': 'Deze week',
    'pl': 'Ten tydzień',
    'cs': 'Tento týden',
    'hu': 'E hét',
    'uk': 'Цей тиждень',
    'ja': '今週',
    'ko': '이번 주',
  });
  String get statsAvgRcs => _t({
    'en': 'Avg RCS',
    'ru': 'Средн. RCS',
    'de': 'Ø RCS',
    'fr': 'Moy. RCS',
    'es': 'Prom. RCS',
    'pt': 'Média RCS',
    'it': 'Media RCS',
    'sv': 'Snitt RCS',
    'fi': 'Ka. RCS',
    'nb': 'Sn. RCS',
    'da': 'Gns. RCS',
    'nl': 'Gem. RCS',
    'pl': 'Śr. RCS',
    'cs': 'Prům. RCS',
    'hu': 'Átl. RCS',
    'uk': 'Сер. RCS',
    'ja': '平均RCS',
    'ko': '평균 RCS',
  });
  String get recentAttacks => _t({
    'en': 'Recent attacks',
    'ru': 'Последние приступы',
    'de': 'Letzte Anfälle',
    'fr': 'Crises récentes',
    'es': 'Crisis recientes',
    'pt': 'Crises recentes',
    'it': 'Crisi recenti',
    'sv': 'Senaste attacker',
    'fi': 'Viimeaikaiset kohtaukset',
    'nb': 'Siste anfall',
    'da': 'Seneste anfald',
    'nl': 'Recente aanvallen',
    'pl': 'Ostatnie ataki',
    'cs': 'Nedávné záchvaty',
    'hu': 'Legutóbbi rohamok',
    'uk': 'Останні напади',
    'ja': '最近の発作',
    'ko': '최근 발작',
  });
  String get weekTrend => _t({
    'en': 'Weekly trend',
    'ru': 'Тренд за неделю',
    'de': 'Wochentrend',
    'fr': 'Tendance hebdo',
    'es': 'Tendencia semanal',
    'pt': 'Tendência semanal',
    'it': 'Tendenza settimanale',
    'sv': 'Veckotrend',
    'fi': 'Viikkotrendi',
    'nb': 'Ukestrend',
    'da': 'Ugetrend',
    'nl': 'Weektrend',
    'pl': 'Trend tygodnia',
    'cs': 'Týdenní trend',
    'hu': 'Heti trend',
    'uk': 'Тренд тижня',
    'ja': '週間トレンド',
    'ko': '주간 추세',
  });
  String get frequentTriggers => _t({
    'en': 'Common triggers (30 days)',
    'ru': 'Частые триггеры (30 дней)',
    'de': 'Häufige Auslöser (30 Tage)',
    'fr': 'Déclencheurs fréquents (30 j.)',
    'es': 'Desencadenantes frecuentes (30 días)',
    'pt': 'Gatilhos frequentes (30 dias)',
    'it': 'Fattori scatenanti frequenti (30 gg)',
    'sv': 'Vanliga utlösare (30 dagar)',
    'fi': 'Yleiset laukaisijat (30 pv)',
    'nb': 'Vanlige utløsere (30 dager)',
    'da': 'Hyppige udløsere (30 dage)',
    'nl': 'Veelvoorkomende triggers (30 dagen)',
    'pl': 'Częste wyzwalacze (30 dni)',
    'cs': 'Časté spouštěče (30 dní)',
    'hu': 'Gyakori kiváltók (30 nap)',
    'uk': 'Часті тригери (30 днів)',
    'ja': '主な誘因（30日間）',
    'ko': '자주 발생하는 유발 요인(30일)',
  });
  String get noRecordsYet => _t({
    'en': 'No records yet',
    'ru': 'Пока нет записей',
    'de': 'Noch keine Einträge',
    'fr': 'Aucune donnée',
    'es': 'Sin registros aún',
    'pt': 'Nenhum registro ainda',
    'it': 'Nessun dato ancora',
    'sv': 'Inga poster ännu',
    'fi': 'Ei vielä merkintöjä',
    'nb': 'Ingen oppføringer ennå',
    'da': 'Ingen data endnu',
    'nl': 'Nog geen gegevens',
    'pl': 'Brak wpisów',
    'cs': 'Zatím žádné záznamy',
    'hu': 'Még nincs bejegyzés',
    'uk': 'Записів ще немає',
    'ja': 'まだ記録がありません',
    'ko': '아직 기록이 없습니다',
  });
  String get tapPlusToRecord => _t({
    'en': 'Tap + to record\nyour first attack',
    'ru': 'Нажми + чтобы записать\nпервый приступ',
    'de': 'Tippe + um den\nersten Anfall zu erfassen',
    'fr': 'Appuyez sur + pour\nenregistrer votre première crise',
    'es': 'Pulsa + para registrar\ntu primera crisis',
    'pt': 'Toque + para registrar\nsua primeira crise',
    'it': 'Tocca + per registrare\nil primo attacco',
    'sv': 'Tryck + för att\nregistrera din första attack',
    'fi': 'Paina + tallentaaksesi\nensimmäisen kohtauksen',
    'nb': 'Trykk + for å registrere\nditt første anfall',
    'da': 'Tryk + for at registrere\ndit første anfald',
    'nl': 'Tik + om je\neerste aanval vast te leggen',
    'pl': 'Naciśnij + aby zapisać\npierwszy atak',
    'cs': 'Klepněte + pro záznam\nprvního záchvatu',
    'hu': 'Nyomd meg a + gombot\naz első roham rögzítéséhez',
    'uk': 'Натисніть + щоб записати\nперший напад',
    'ja': '+をタップして\n最初の発作を記録',
    'ko': '+를 눌러\n첫 번째 발작을 기록하세요',
  });
  String get attackDeleted => _t({
    'en': 'Attack deleted',
    'ru': 'Приступ удалён',
    'de': 'Anfall gelöscht',
    'fr': 'Crise supprimée',
    'es': 'Crisis eliminada',
    'pt': 'Crise excluída',
    'it': 'Crisi eliminata',
    'sv': 'Attack raderad',
    'fi': 'Kohtaus poistettu',
    'nb': 'Anfall slettet',
    'da': 'Anfald slettet',
    'nl': 'Aanval verwijderd',
    'pl': 'Atak usunięty',
    'cs': 'Záchvat smazán',
    'hu': 'Roham törölve',
    'uk': 'Напад видалено',
    'ja': '発作を削除しました',
    'ko': '발작 삭제됨',
  });
  String get undo => _t({
    'en': 'Undo',
    'ru': 'Отменить',
    'de': 'Rückgängig',
    'fr': 'Annuler',
    'es': 'Deshacer',
    'pt': 'Desfazer',
    'it': 'Annulla',
    'sv': 'Ångra',
    'fi': 'Kumoa',
    'nb': 'Angre',
    'da': 'Fortryd',
    'nl': 'Ongedaan maken',
    'pl': 'Cofnij',
    'cs': 'Zpět',
    'hu': 'Visszavonás',
    'uk': 'Скасувати',
    'ja': '元に戻す',
    'ko': '실행 취소',
  });
  String get frostWarning => _t({
    'en': 'Freezing! High attack risk. Keep hands warm.',
    'ru': 'Мороз! Высокий риск приступа. Утепляйте руки.',
    'de': 'Frost! Hohes Anfallrisiko. Hände warm halten.',
    'fr': 'Gel ! Risque élevé de crise. Gardez vos mains au chaud.',
    'es': '¡Helada! Alto riesgo de crisis. Mantén las manos calientes.',
    'pt': 'Geada! Alto risco de crise. Mantenha as mãos aquecidas.',
    'it': 'Gelo! Alto rischio di crisi. Tieni le mani al caldo.',
    'sv': 'Frost! Hög attackrisk. Håll händerna varma.',
    'fi': 'Pakkanen! Korkea kohtausriski. Pidä kädet lämpiminä.',
    'nb': 'Frost! Høy anfallsrisiko. Hold hendene varme.',
    'da': 'Frost! Høj anfaldrisiko. Hold hænderne varme.',
    'nl': 'Vorst! Hoog aanvalrisico. Houd uw handen warm.',
    'pl': 'Mróz! Wysokie ryzyko ataku. Trzymaj ręce w cieple.',
    'cs': 'Mráz! Vysoké riziko záchvatu. Udržujte ruce v teple.',
    'hu': 'Fagy! Magas rohamkockázat. Tartsa melegen a kezeit.',
    'uk': 'Мороз! Високий ризик нападу. Тримайте руки в теплі.',
    'ja': '凍結注意！発作リスクが高いです。手を温かく保ちましょう。',
    'ko': '영하! 발작 위험이 높습니다. 손을 따뜻하게 유지하세요.',
  });
  String get coldWarning => _t({
    'en': 'Cool weather. Protect your hands.',
    'ru': 'Прохладно. Берегите руки от холода.',
    'de': 'Kühl. Schützen Sie Ihre Hände.',
    'fr': 'Temps frais. Protégez vos mains.',
    'es': 'Tiempo fresco. Protege tus manos.',
    'pt': 'Tempo frio. Proteja suas mãos.',
    'it': 'Tempo fresco. Proteggi le mani.',
    'sv': 'Kyligt. Skydda dina händer.',
    'fi': 'Viileää. Suojaa kätesi.',
    'nb': 'Kjølig. Beskytt hendene.',
    'da': 'Køligt. Beskyt dine hænder.',
    'nl': 'Koel. Bescherm uw handen.',
    'pl': 'Chłodno. Chroń dłonie.',
    'cs': 'Chladno. Chraňte si ruce.',
    'hu': 'Hűvös. Védje a kezeit.',
    'uk': 'Прохолодно. Бережіть руки.',
    'ja': '涼しい天気です。手を守りましょう。',
    'ko': '서늘한 날씨입니다. 손을 보호하세요.',
  });

  // === Streak ===
  String daysWithout(int days) {
    final l = _lang;
    if (l == 'ru') return '$days ${_daysLabelRu(days)} без приступа';
    if (l == 'uk') return '$days ${_daysLabelUk(days)} без нападу';
    if (l == 'de') return '$days ${days == 1 ? "Tag" : "Tage"} ohne Anfall';
    if (l == 'fr') return '$days ${days == 1 ? "jour" : "jours"} sans crise';
    if (l == 'es') return '$days ${days == 1 ? "día" : "días"} sin crisis';
    if (l == 'pt') return '$days ${days == 1 ? "dia" : "dias"} sem crise';
    if (l == 'it')
      return '$days ${days == 1 ? "giorno" : "giorni"} senza crisi';
    if (l == 'sv') return '$days ${days == 1 ? "dag" : "dagar"} utan attack';
    if (l == 'fi')
      return '$days ${days == 1 ? "päivä" : "päivää"} ilman kohtausta';
    if (l == 'nb') return '$days ${days == 1 ? "dag" : "dager"} uten anfall';
    if (l == 'da') return '$days ${days == 1 ? "dag" : "dage"} uden anfald';
    if (l == 'nl') return '$days ${days == 1 ? "dag" : "dagen"} zonder aanval';
    if (l == 'pl') return '$days ${_daysLabelPl(days)} bez ataku';
    if (l == 'cs') return '$days ${_daysLabelCs(days)} bez záchvatu';
    if (l == 'hu') return '$days nap roham nélkül';
    if (l == 'ja') return '発作なし$days日';
    if (l == 'ko') return '발작 없이 $days일';
    return '$days ${days == 1 ? "day" : "days"} attack-free';
  }

  String get streakKeepGoing => _t({
    'en': 'Stay strong!',
    'ru': 'Держись, ты справишься!',
    'de': 'Bleib stark!',
    'fr': 'Courage !',
    'es': '¡Ánimo!',
    'pt': 'Força!',
    'it': 'Forza!',
    'sv': 'Håll ut!',
    'fi': 'Pidä pintasi!',
    'nb': 'Hold ut!',
    'da': 'Hold ud!',
    'nl': 'Houd vol!',
    'pl': 'Trzymaj się!',
    'cs': 'Drž se!',
    'hu': 'Tartsd ki!',
    'uk': 'Тримайся!',
    'ja': '頑張って！',
    'ko': '힘내세요!',
  });
  String get streakGoodStart => _t({
    'en': 'Good start!',
    'ru': 'Хорошее начало!',
    'de': 'Guter Anfang!',
    'fr': 'Bon début !',
    'es': '¡Buen comienzo!',
    'pt': 'Bom começo!',
    'it': 'Buon inizio!',
    'sv': 'Bra start!',
    'fi': 'Hyvä alku!',
    'nb': 'God start!',
    'da': 'God start!',
    'nl': 'Goed begin!',
    'pl': 'Dobry początek!',
    'cs': 'Dobrý začátek!',
    'hu': 'Jó kezdés!',
    'uk': 'Гарний початок!',
    'ja': '良いスタートです！',
    'ko': '좋은 시작이에요!',
  });
  String get streakGreatStreak => _t({
    'en': 'Great streak!',
    'ru': 'Отличная серия!',
    'de': 'Tolle Serie!',
    'fr': 'Belle série !',
    'es': '¡Gran racha!',
    'pt': 'Ótima sequência!',
    'it': 'Ottima serie!',
    'sv': 'Fin svit!',
    'fi': 'Hieno putki!',
    'nb': 'Flott serie!',
    'da': 'Flot serie!',
    'nl': 'Mooie reeks!',
    'pl': 'Świetna seria!',
    'cs': 'Skvělá série!',
    'hu': 'Nagyszerű széria!',
    'uk': 'Чудова серія!',
    'ja': '素晴らしい連続記録！',
    'ko': '훌륭한 연속 기록!',
  });
  String get streakAmazing => _t({
    'en': 'Amazing result!',
    'ru': 'Потрясающий результат!',
    'de': 'Erstaunliches Ergebnis!',
    'fr': 'Résultat incroyable !',
    'es': '¡Resultado increíble!',
    'pt': 'Resultado incrível!',
    'it': 'Risultato straordinario!',
    'sv': 'Fantastiskt resultat!',
    'fi': 'Upea tulos!',
    'nb': 'Fantastisk resultat!',
    'da': 'Fantastisk resultat!',
    'nl': 'Geweldig resultaat!',
    'pl': 'Niesamowity wynik!',
    'cs': 'Úžasný výsledek!',
    'hu': 'Elképesztő eredmény!',
    'uk': 'Вражаючий результат!',
    'ja': '驚異的な結果！',
    'ko': '놀라운 결과!',
  });

  // Склонение дней
  String _daysLabelRu(int d) {
    if (d % 10 == 1 && d % 100 != 11) return 'день';
    if (d % 10 >= 2 && d % 10 <= 4 && (d % 100 < 10 || d % 100 >= 20))
      return 'дня';
    return 'дней';
  }

  String _daysLabelUk(int d) {
    if (d % 10 == 1 && d % 100 != 11) return 'день';
    if (d % 10 >= 2 && d % 10 <= 4 && (d % 100 < 10 || d % 100 >= 20))
      return 'дні';
    return 'днів';
  }

  String _daysLabelPl(int d) {
    if (d == 1) return 'dzień';
    if (d % 10 >= 2 && d % 10 <= 4 && (d % 100 < 10 || d % 100 >= 20))
      return 'dni';
    return 'dni';
  }

  String _daysLabelCs(int d) {
    if (d == 1) return 'den';
    if (d >= 2 && d <= 4) return 'dny';
    return 'dní';
  }

  // === Запись приступа ===
  String get recordAttack => _t({
    'en': 'Record attack',
    'ru': 'Записать приступ',
    'de': 'Anfall erfassen',
    'fr': 'Enregistrer une crise',
    'es': 'Registrar crisis',
    'pt': 'Registrar crise',
    'it': 'Registra crisi',
    'sv': 'Registrera attack',
    'fi': 'Kirjaa kohtaus',
    'nb': 'Registrer anfall',
    'da': 'Registrer anfald',
    'nl': 'Aanval registreren',
    'pl': 'Zapisz atak',
    'cs': 'Zaznamenat záchvat',
    'hu': 'Roham rögzítése',
    'uk': 'Записати напад',
    'ja': '発作を記録',
    'ko': '발작 기록',
  });
  String get editAttack => _t({
    'en': 'Edit',
    'ru': 'Редактировать',
    'de': 'Bearbeiten',
    'fr': 'Modifier',
    'es': 'Editar',
    'pt': 'Editar',
    'it': 'Modifica',
    'sv': 'Redigera',
    'fi': 'Muokkaa',
    'nb': 'Rediger',
    'da': 'Rediger',
    'nl': 'Bewerken',
    'pl': 'Edytuj',
    'cs': 'Upravit',
    'hu': 'Szerkesztés',
    'uk': 'Редагувати',
    'ja': '編集',
    'ko': '편집',
  });
  String get likeLastTime => _t({
    'en': 'Same as last time',
    'ru': 'Как прошлый раз',
    'de': 'Wie letztes Mal',
    'fr': 'Comme la dernière fois',
    'es': 'Como la última vez',
    'pt': 'Como da última vez',
    'it': "Come l'ultima volta",
    'sv': 'Som förra gången',
    'fi': 'Kuten viimeksi',
    'nb': 'Som forrige gang',
    'da': 'Som sidste gang',
    'nl': 'Zoals vorige keer',
    'pl': 'Jak ostatnio',
    'cs': 'Jako minule',
    'hu': 'Mint legutóbb',
    'uk': 'Як минулого разу',
    'ja': '前回と同じ',
    'ko': '지난번과 동일',
  });
  String get sectionAssessment => _t({
    'en': 'Attack assessment',
    'ru': 'Оценка приступа',
    'de': 'Anfallbewertung',
    'fr': 'Évaluation de la crise',
    'es': 'Evaluación de la crisis',
    'pt': 'Avaliação da crise',
    'it': 'Valutazione della crisi',
    'sv': 'Attackbedömning',
    'fi': 'Kohtauksen arviointi',
    'nb': 'Anfallsvurdering',
    'da': 'Anfaldsvurdering',
    'nl': 'Aanvalbeoordeling',
    'pl': 'Ocena ataku',
    'cs': 'Hodnocení záchvatu',
    'hu': 'Roham értékelése',
    'uk': 'Оцінка нападу',
    'ja': '発作の評価',
    'ko': '발작 평가',
  });
  String get severityRcs => _t({
    'en': 'Severity (RCS)',
    'ru': 'Тяжесть (RCS)',
    'de': 'Schwere (RCS)',
    'fr': 'Sévérité (RCS)',
    'es': 'Gravedad (RCS)',
    'pt': 'Gravidade (RCS)',
    'it': 'Gravità (RCS)',
    'sv': 'Svårighetsgrad (RCS)',
    'fi': 'Vakavuus (RCS)',
    'nb': 'Alvorlighetsgrad (RCS)',
    'da': 'Sværhedsgrad (RCS)',
    'nl': 'Ernst (RCS)',
    'pl': 'Ciężkość (RCS)',
    'cs': 'Závažnost (RCS)',
    'hu': 'Súlyosság (RCS)',
    'uk': 'Тяжкість (RCS)',
    'ja': '重症度 (RCS)',
    'ko': '심각도 (RCS)',
  });
  String get fingerColor => _t({
    'en': 'Finger color',
    'ru': 'Цвет пальцев',
    'de': 'Fingerfarbe',
    'fr': 'Couleur des doigts',
    'es': 'Color de los dedos',
    'pt': 'Cor dos dedos',
    'it': 'Colore delle dita',
    'sv': 'Fingerfärg',
    'fi': 'Sormien väri',
    'nb': 'Fingerfarge',
    'da': 'Fingerfarve',
    'nl': 'Vingerkleur',
    'pl': 'Kolor palców',
    'cs': 'Barva prstů',
    'hu': 'Ujjszín',
    'uk': 'Колір пальців',
    'ja': '指の色',
    'ko': '손가락 색상',
  });
  String get duration => _t({
    'en': 'Duration',
    'ru': 'Длительность',
    'de': 'Dauer',
    'fr': 'Durée',
    'es': 'Duración',
    'pt': 'Duração',
    'it': 'Durata',
    'sv': 'Varaktighet',
    'fi': 'Kesto',
    'nb': 'Varighet',
    'da': 'Varighed',
    'nl': 'Duur',
    'pl': 'Czas trwania',
    'cs': 'Trvání',
    'hu': 'Időtartam',
    'uk': 'Тривалість',
    'ja': '持続時間',
    'ko': '지속 시간',
  });
  String get sectionTriggers => _t({
    'en': 'What triggered it?',
    'ru': 'Что вызвало?',
    'de': 'Was hat es ausgelöst?',
    'fr': 'Quel déclencheur ?',
    'es': '¿Qué lo provocó?',
    'pt': 'O que provocou?',
    'it': 'Cosa lo ha scatenato?',
    'sv': 'Vad utlöste det?',
    'fi': 'Mikä aiheutti?',
    'nb': 'Hva utløste det?',
    'da': 'Hvad udløste det?',
    'nl': 'Wat veroorzaakte het?',
    'pl': 'Co spowodowało?',
    'cs': 'Co to vyvolalo?',
    'hu': 'Mi váltotta ki?',
    'uk': 'Що викликало?',
    'ja': '何が引き起こしましたか？',
    'ko': '원인은 무엇인가요?',
  });
  String get sectionFingers => _t({
    'en': 'Affected fingers',
    'ru': 'Поражённые пальцы',
    'de': 'Betroffene Finger',
    'fr': 'Doigts affectés',
    'es': 'Dedos afectados',
    'pt': 'Dedos afetados',
    'it': 'Dita colpite',
    'sv': 'Drabbade fingrar',
    'fi': 'Oireilevat sormet',
    'nb': 'Berørte fingre',
    'da': 'Berørte fingre',
    'nl': 'Getroffen vingers',
    'pl': 'Dotknięte palce',
    'cs': 'Postižené prsty',
    'hu': 'Érintett ujjak',
    'uk': 'Уражені пальці',
    'ja': '影響を受けた指',
    'ko': '영향 받은 손가락',
  });
  String get sectionExtra => _t({
    'en': 'Additional',
    'ru': 'Дополнительно',
    'de': 'Zusätzlich',
    'fr': 'Compléments',
    'es': 'Adicional',
    'pt': 'Adicional',
    'it': 'Aggiuntivo',
    'sv': 'Övrigt',
    'fi': 'Lisätiedot',
    'nb': 'Tillegg',
    'da': 'Yderligere',
    'nl': 'Extra',
    'pl': 'Dodatkowe',
    'cs': 'Doplňující',
    'hu': 'Kiegészítő',
    'uk': 'Додатково',
    'ja': '追加情報',
    'ko': '추가 정보',
  });
  String get takePhoto => _t({
    'en': 'Take photo',
    'ru': 'Сделать фото',
    'de': 'Foto aufnehmen',
    'fr': 'Prendre une photo',
    'es': 'Tomar foto',
    'pt': 'Tirar foto',
    'it': 'Scatta foto',
    'sv': 'Ta foto',
    'fi': 'Ota kuva',
    'nb': 'Ta bilde',
    'da': 'Tag foto',
    'nl': 'Foto nemen',
    'pl': 'Zrób zdjęcie',
    'cs': 'Vyfotit',
    'hu': 'Fénykép',
    'uk': 'Зробити фото',
    'ja': '写真を撮る',
    'ko': '사진 촬영',
  });
  String get retakePhoto => _t({
    'en': 'Retake',
    'ru': 'Переснять',
    'de': 'Neu aufnehmen',
    'fr': 'Reprendre',
    'es': 'Repetir',
    'pt': 'Refazer',
    'it': 'Ripeti',
    'sv': 'Ta om',
    'fi': 'Ota uudelleen',
    'nb': 'Ta på nytt',
    'da': 'Tag igen',
    'nl': 'Opnieuw',
    'pl': 'Powtórz',
    'cs': 'Znovu',
    'hu': 'Újra',
    'uk': 'Перезняти',
    'ja': '撮り直す',
    'ko': '다시 촬영',
  });
  String get notesOptional => _t({
    'en': 'Notes (optional)',
    'ru': 'Заметки (необязательно)',
    'de': 'Notizen (optional)',
    'fr': 'Notes (facultatif)',
    'es': 'Notas (opcional)',
    'pt': 'Notas (opcional)',
    'it': 'Note (facoltativo)',
    'sv': 'Anteckningar (valfritt)',
    'fi': 'Muistiinpanot (valinnainen)',
    'nb': 'Notater (valgfritt)',
    'da': 'Bemærkninger (valgfrit)',
    'nl': 'Notities (optioneel)',
    'pl': 'Notatki (opcjonalne)',
    'cs': 'Poznámky (nepovinné)',
    'hu': 'Jegyzetek (opcionális)',
    'uk': "Нотатки (необов'язково)",
    'ja': 'メモ（任意）',
    'ko': '메모 (선택사항)',
  });
  String get notesHint => _t({
    'en': 'Additional details...',
    'ru': 'Дополнительные детали...',
    'de': 'Weitere Details...',
    'fr': 'Détails supplémentaires...',
    'es': 'Detalles adicionales...',
    'pt': 'Detalhes adicionais...',
    'it': 'Ulteriori dettagli...',
    'sv': 'Ytterligare detaljer...',
    'fi': 'Lisätietoja...',
    'nb': 'Flere detaljer...',
    'da': 'Yderligere detaljer...',
    'nl': 'Meer details...',
    'pl': 'Dodatkowe szczegóły...',
    'cs': 'Další podrobnosti...',
    'hu': 'További részletek...',
    'uk': 'Додаткові деталі...',
    'ja': '詳細を入力...',
    'ko': '추가 세부사항...',
  });
  String get attackSaved => _t({
    'en': 'Attack recorded',
    'ru': 'Приступ записан',
    'de': 'Anfall gespeichert',
    'fr': 'Crise enregistrée',
    'es': 'Crisis registrada',
    'pt': 'Crise registrada',
    'it': 'Crisi registrata',
    'sv': 'Attack registrerad',
    'fi': 'Kohtaus tallennettu',
    'nb': 'Anfall registrert',
    'da': 'Anfald registreret',
    'nl': 'Aanval opgeslagen',
    'pl': 'Atak zapisany',
    'cs': 'Záchvat uložen',
    'hu': 'Roham rögzítve',
    'uk': 'Напад записано',
    'ja': '発作を記録しました',
    'ko': '발작이 기록되었습니다',
  });
  String get attackUpdated => _t({
    'en': 'Attack updated',
    'ru': 'Приступ обновлён',
    'de': 'Anfall aktualisiert',
    'fr': 'Crise mise à jour',
    'es': 'Crisis actualizada',
    'pt': 'Crise atualizada',
    'it': 'Crisi aggiornata',
    'sv': 'Attack uppdaterad',
    'fi': 'Kohtaus päivitetty',
    'nb': 'Anfall oppdatert',
    'da': 'Anfald opdateret',
    'nl': 'Aanval bijgewerkt',
    'pl': 'Atak zaktualizowany',
    'cs': 'Záchvat aktualizován',
    'hu': 'Roham frissítve',
    'uk': 'Напад оновлено',
    'ja': '発作を更新しました',
    'ko': '발작이 업데이트되었습니다',
  });
  String get leftHand => _t({
    'en': 'Left',
    'ru': 'Левая',
    'de': 'Links',
    'fr': 'Gauche',
    'es': 'Izquierda',
    'pt': 'Esquerda',
    'it': 'Sinistra',
    'sv': 'Vänster',
    'fi': 'Vasen',
    'nb': 'Venstre',
    'da': 'Venstre',
    'nl': 'Links',
    'pl': 'Lewa',
    'cs': 'Levá',
    'hu': 'Bal',
    'uk': 'Ліва',
    'ja': '左',
    'ko': '왼손',
  });
  String get rightHand => _t({
    'en': 'Right',
    'ru': 'Правая',
    'de': 'Rechts',
    'fr': 'Droite',
    'es': 'Derecha',
    'pt': 'Direita',
    'it': 'Destra',
    'sv': 'Höger',
    'fi': 'Oikea',
    'nb': 'Høyre',
    'da': 'Højre',
    'nl': 'Rechts',
    'pl': 'Prawa',
    'cs': 'Pravá',
    'hu': 'Jobb',
    'uk': 'Права',
    'ja': '右',
    'ko': '오른손',
  });

  // === Цветовые фазы ===
  String get phaseWhite => _t({
    'en': 'White',
    'ru': 'Белый',
    'de': 'Weiß',
    'fr': 'Blanc',
    'es': 'Blanco',
    'pt': 'Branco',
    'it': 'Bianco',
    'sv': 'Vit',
    'fi': 'Valkoinen',
    'nb': 'Hvit',
    'da': 'Hvid',
    'nl': 'Wit',
    'pl': 'Biały',
    'cs': 'Bílá',
    'hu': 'Fehér',
    'uk': 'Білий',
    'ja': '白',
    'ko': '흰색',
  });
  String get phaseBlue => _t({
    'en': 'Blue',
    'ru': 'Синий',
    'de': 'Blau',
    'fr': 'Bleu',
    'es': 'Azul',
    'pt': 'Azul',
    'it': 'Blu',
    'sv': 'Blå',
    'fi': 'Sininen',
    'nb': 'Blå',
    'da': 'Blå',
    'nl': 'Blauw',
    'pl': 'Niebieski',
    'cs': 'Modrá',
    'hu': 'Kék',
    'uk': 'Синій',
    'ja': '青',
    'ko': '파란색',
  });
  String get phaseRed => _t({
    'en': 'Red',
    'ru': 'Красный',
    'de': 'Rot',
    'fr': 'Rouge',
    'es': 'Rojo',
    'pt': 'Vermelho',
    'it': 'Rosso',
    'sv': 'Röd',
    'fi': 'Punainen',
    'nb': 'Rød',
    'da': 'Rød',
    'nl': 'Rood',
    'pl': 'Czerwony',
    'cs': 'Červená',
    'hu': 'Piros',
    'uk': 'Червоний',
    'ja': '赤',
    'ko': '빨간색',
  });
  String get phaseMixed => _t({
    'en': 'Mixed',
    'ru': 'Смешан.',
    'de': 'Gemischt',
    'fr': 'Mixte',
    'es': 'Mixto',
    'pt': 'Misto',
    'it': 'Misto',
    'sv': 'Blandat',
    'fi': 'Seka',
    'nb': 'Blandet',
    'da': 'Blandet',
    'nl': 'Gemengd',
    'pl': 'Mieszany',
    'cs': 'Smíšená',
    'hu': 'Vegyes',
    'uk': 'Змішан.',
    'ja': '混合',
    'ko': '혼합',
  });

  /// Аббревиатуры дней недели [Пн..Вс] для графиков (индекс 0=Пн, 6=Вс)
  List<String> get weekdayAbbrs => [
    _t({'en':'Mo','ru':'Пн','de':'Mo','fr':'Lu','es':'Lu','pt':'Seg','it':'Lu','sv':'Mån','fi':'Ma','nb':'Ma','da':'Ma','nl':'Ma','pl':'Pon','cs':'Po','hu':'H','uk':'Пн','ja':'月','ko':'월'}),
    _t({'en':'Tu','ru':'Вт','de':'Di','fr':'Ma','es':'Ma','pt':'Ter','it':'Ma','sv':'Ti','fi':'Ti','nb':'Ti','da':'Ti','nl':'Di','pl':'Wt','cs':'Út','hu':'K','uk':'Вт','ja':'火','ko':'화'}),
    _t({'en':'We','ru':'Ср','de':'Mi','fr':'Me','es':'Mi','pt':'Qua','it':'Me','sv':'On','fi':'Ke','nb':'On','da':'On','nl':'Wo','pl':'Śr','cs':'St','hu':'Sz','uk':'Ср','ja':'水','ko':'수'}),
    _t({'en':'Th','ru':'Чт','de':'Do','fr':'Je','es':'Ju','pt':'Qui','it':'Gi','sv':'To','fi':'To','nb':'To','da':'To','nl':'Do','pl':'Czw','cs':'Čt','hu':'Cs','uk':'Чт','ja':'木','ko':'목'}),
    _t({'en':'Fr','ru':'Пт','de':'Fr','fr':'Ve','es':'Vi','pt':'Sex','it':'Ve','sv':'Fr','fi':'Pe','nb':'Fr','da':'Fr','nl':'Vr','pl':'Pt','cs':'Pá','hu':'P','uk':'Пт','ja':'金','ko':'금'}),
    _t({'en':'Sa','ru':'Сб','de':'Sa','fr':'Sa','es':'Sá','pt':'Sáb','it':'Sa','sv':'Lö','fi':'La','nb':'Lø','da':'Lø','nl':'Za','pl':'So','cs':'So','hu':'Szo','uk':'Сб','ja':'土','ko':'토'}),
    _t({'en':'Su','ru':'Вс','de':'So','fr':'Di','es':'Do','pt':'Dom','it':'Do','sv':'Sö','fi':'Su','nb':'Sø','da':'Sø','nl':'Zo','pl':'Nie','cs':'Ne','hu':'V','uk':'Нд','ja':'日','ko':'일'}),
  ];

  /// Локализованное название фазы по ключу хранения ('white'/'blue'/'red'/'mixed')
  String phaseFromKey(String key) {
    switch (key) {
      case 'white':
        return phaseWhite;
      case 'blue':
        return phaseBlue;
      case 'red':
        return phaseRed;
      case 'mixed':
        return phaseMixed;
      default:
        return key;
    }
  }

  /// "Нет данных" / "N/A" в отчётах и UI
  String get notAvailable => _t({
    'en': 'N/A',
    'ru': 'Нет данных',
    'de': 'Keine Daten',
    'fr': 'Non dispo.',
    'es': 'Sin datos',
    'pt': 'Sem dados',
    'it': 'Nessun dato',
    'sv': 'Inga data',
    'fi': 'Ei tietoja',
    'nb': 'Ingen data',
    'da': 'Ingen data',
    'nl': 'Geen gegevens',
    'pl': 'Brak danych',
    'cs': 'Žádná data',
    'hu': 'Nincs adat',
    'uk': 'Немає даних',
    'ja': 'データなし',
    'ko': '데이터 없음',
  });

  // === Триггеры ===
  String get triggerCold => _t({
    'en': 'Cold',
    'ru': 'Холод',
    'de': 'Kälte',
    'fr': 'Froid',
    'es': 'Frío',
    'pt': 'Frio',
    'it': 'Freddo',
    'sv': 'Kyla',
    'fi': 'Kylmyys',
    'nb': 'Kulde',
    'da': 'Kulde',
    'nl': 'Koude',
    'pl': 'Zimno',
    'cs': 'Chlad',
    'hu': 'Hideg',
    'uk': 'Холод',
    'ja': '寒さ',
    'ko': '추위',
  });
  String get triggerStress => _t({
    'en': 'Stress',
    'ru': 'Стресс',
    'de': 'Stress',
    'fr': 'Stress',
    'es': 'Estrés',
    'pt': 'Estresse',
    'it': 'Stress',
    'sv': 'Stress',
    'fi': 'Stressi',
    'nb': 'Stress',
    'da': 'Stress',
    'nl': 'Stress',
    'pl': 'Stres',
    'cs': 'Stres',
    'hu': 'Stressz',
    'uk': 'Стрес',
    'ja': 'ストレス',
    'ko': '스트레스',
  });
  String get triggerColdWater => _t({
    'en': 'Cold water',
    'ru': 'Холодная вода',
    'de': 'Kaltes Wasser',
    'fr': 'Eau froide',
    'es': 'Agua fría',
    'pt': 'Água fria',
    'it': 'Acqua fredda',
    'sv': 'Kallt vatten',
    'fi': 'Kylmä vesi',
    'nb': 'Kaldt vann',
    'da': 'Koldt vand',
    'nl': 'Koud water',
    'pl': 'Zimna woda',
    'cs': 'Studená voda',
    'hu': 'Hideg víz',
    'uk': 'Холодна вода',
    'ja': '冷水',
    'ko': '찬물',
  });
  String get triggerAC => _t({
    'en': 'A/C',
    'ru': 'Кондиционер',
    'de': 'Klimaanlage',
    'fr': 'Climatisation',
    'es': 'Aire acond.',
    'pt': 'Ar-cond.',
    'it': 'Aria cond.',
    'sv': 'AC',
    'fi': 'Ilmastointi',
    'nb': 'Klimaanlegg',
    'da': 'Aircondition',
    'nl': 'Airco',
    'pl': 'Klimatyzacja',
    'cs': 'Klimatizace',
    'hu': 'Légkondicionáló',
    'uk': 'Кондиціонер',
    'ja': 'エアコン',
    'ko': '에어컨',
  });
  String get triggerVibration => _t({
    'en': 'Vibration',
    'ru': 'Вибрация',
    'de': 'Vibration',
    'fr': 'Vibration',
    'es': 'Vibración',
    'pt': 'Vibração',
    'it': 'Vibrazione',
    'sv': 'Vibration',
    'fi': 'Tärinä',
    'nb': 'Vibrasjon',
    'da': 'Vibration',
    'nl': 'Trillingen',
    'pl': 'Wibracje',
    'cs': 'Vibrace',
    'hu': 'Rezgés',
    'uk': 'Вібрація',
    'ja': '振動',
    'ko': '진동',
  });
  String get triggerSmoking => _t({
    'en': 'Smoking',
    'ru': 'Курение',
    'de': 'Rauchen',
    'fr': 'Tabac',
    'es': 'Tabaco',
    'pt': 'Tabaco',
    'it': 'Fumo',
    'sv': 'Rökning',
    'fi': 'Tupakointi',
    'nb': 'Røyking',
    'da': 'Rygning',
    'nl': 'Roken',
    'pl': 'Palenie',
    'cs': 'Kouření',
    'hu': 'Dohányzás',
    'uk': 'Куріння',
    'ja': '喫煙',
    'ko': '흡연',
  });
  String get triggerCaffeine => _t({
    'en': 'Caffeine',
    'ru': 'Кофеин',
    'de': 'Koffein',
    'fr': 'Caféine',
    'es': 'Cafeína',
    'pt': 'Cafeína',
    'it': 'Caffeina',
    'sv': 'Koffein',
    'fi': 'Kofeiini',
    'nb': 'Koffein',
    'da': 'Koffein',
    'nl': 'Cafeïne',
    'pl': 'Kofeina',
    'cs': 'Kofein',
    'hu': 'Koffein',
    'uk': 'Кофеїн',
    'ja': 'カフェイン',
    'ko': '카페인',
  });
  String get triggerExercise => _t({
    'en': 'Exercise',
    'ru': 'Физ. нагрузка',
    'de': 'Sport',
    'fr': 'Exercice',
    'es': 'Ejercicio',
    'pt': 'Exercício',
    'it': 'Esercizio',
    'sv': 'Motion',
    'fi': 'Liikunta',
    'nb': 'Trening',
    'da': 'Motion',
    'nl': 'Sport',
    'pl': 'Wysiłek',
    'cs': 'Cvičení',
    'hu': 'Testmozgás',
    'uk': 'Фіз. навантаження',
    'ja': '運動',
    'ko': '운동',
  });
  String get triggerEmotions => _t({
    'en': 'Emotions',
    'ru': 'Эмоции',
    'de': 'Emotionen',
    'fr': 'Émotions',
    'es': 'Emociones',
    'pt': 'Emoções',
    'it': 'Emozioni',
    'sv': 'Känslor',
    'fi': 'Tunteet',
    'nb': 'Følelser',
    'da': 'Følelser',
    'nl': 'Emoties',
    'pl': 'Emocje',
    'cs': 'Emoce',
    'hu': 'Érzelmek',
    'uk': 'Емоції',
    'ja': '感情',
    'ko': '감정',
  });
  String get triggerMedication => _t({
    'en': 'Medication',
    'ru': 'Лекарства',
    'de': 'Medikamente',
    'fr': 'Médicaments',
    'es': 'Medicación',
    'pt': 'Medicação',
    'it': 'Farmaci',
    'sv': 'Medicin',
    'fi': 'Lääkitys',
    'nb': 'Medisin',
    'da': 'Medicin',
    'nl': 'Medicatie',
    'pl': 'Leki',
    'cs': 'Léky',
    'hu': 'Gyógyszer',
    'uk': 'Ліки',
    'ja': '薬',
    'ko': '약물',
  });
  String get triggerUnknown => _t({
    'en': 'Unknown',
    'ru': 'Неизвестно',
    'de': 'Unbekannt',
    'fr': 'Inconnu',
    'es': 'Desconocido',
    'pt': 'Desconhecido',
    'it': 'Sconosciuto',
    'sv': 'Okänt',
    'fi': 'Tuntematon',
    'nb': 'Ukjent',
    'da': 'Ukendt',
    'nl': 'Onbekend',
    'pl': 'Nieznane',
    'cs': 'Neznámé',
    'hu': 'Ismeretlen',
    'uk': 'Невідомо',
    'ja': '不明',
    'ko': '알 수 없음',
  });

  // === Онбординг ===
  String get onb1Title => _t({
    'en': "Track Raynaud's attacks",
    'ru': 'Отслеживай приступы Рейно',
    'de': 'Raynaud-Anfälle verfolgen',
    'fr': 'Suivez vos crises de Raynaud',
    'es': 'Registra tus crisis de Raynaud',
    'pt': 'Acompanhe suas crises de Raynaud',
    'it': 'Monitora le crisi di Raynaud',
    'sv': 'Spåra Raynaud-attacker',
    'fi': 'Seuraa Raynaud-kohtauksia',
    'nb': 'Spor Raynaud-anfall',
    'da': 'Spor Raynaud-anfald',
    'nl': 'Volg Raynaud-aanvallen',
    'pl': 'Śledź ataki Raynauda',
    'cs': 'Sledujte záchvaty Raynaudova syndromu',
    'hu': 'Kövesse nyomon Raynaud-rohamait',
    'uk': 'Відстежуйте напади Рейно',
    'ja': 'レイノー発作を記録',
    'ko': '레이노 발작 추적',
  });
  String get onb1Desc => _t({
    'en':
        'Log every attack: severity, color, affected fingers, triggers and duration.',
    'ru':
        'Записывай каждый приступ: тяжесть, цвет, поражённые пальцы, триггеры и длительность.',
    'de':
        'Erfasse jeden Anfall: Schwere, Farbe, betroffene Finger, Auslöser und Dauer.',
    'fr':
        'Notez chaque crise : sévérité, couleur, doigts affectés, déclencheurs et durée.',
    'es':
        'Registra cada crisis: gravedad, color, dedos afectados, desencadenantes y duración.',
    'pt':
        'Registre cada crise: gravidade, cor, dedos afetados, gatilhos e duração.',
    'it':
        'Registra ogni crisi: gravità, colore, dita colpite, fattori scatenanti e durata.',
    'sv':
        'Logga varje attack: svårighetsgrad, färg, drabbade fingrar, utlösare och varaktighet.',
    'fi':
        'Kirjaa jokainen kohtaus: vakavuus, väri, oireilevat sormet, laukaisijat ja kesto.',
    'nb':
        'Logg hvert anfall: alvorlighetsgrad, farge, berørte fingre, utløsere og varighet.',
    'da':
        'Log hvert anfald: sværhedsgrad, farve, berørte fingre, udløsere og varighed.',
    'nl': 'Log elke aanval: ernst, kleur, getroffen vingers, triggers en duur.',
    'pl':
        'Zapisuj każdy atak: ciężkość, kolor, dotknięte palce, wyzwalacze i czas trwania.',
    'cs':
        'Zaznamenávejte každý záchvat: závažnost, barva, postižené prsty, spouštěče a trvání.',
    'hu':
        'Rögzítsen minden rohamot: súlyosság, szín, érintett ujjak, kiváltók és időtartam.',
    'uk':
        'Записуйте кожен напад: тяжкість, колір, уражені пальці, тригери та тривалість.',
    'ja': '発作を記録：重症度、色、影響を受けた指、誘因、持続時間。',
    'ko': '모든 발작을 기록하세요: 심각도, 색상, 영향 받은 손가락, 유발 요인, 지속 시간.',
  });
  String get onb2Title => _t({
    'en': 'Automatic weather',
    'ru': 'Автоматическая погода',
    'de': 'Automatisches Wetter',
    'fr': 'Météo automatique',
    'es': 'Clima automático',
    'pt': 'Clima automático',
    'it': 'Meteo automatico',
    'sv': 'Automatiskt väder',
    'fi': 'Automaattinen sää',
    'nb': 'Automatisk vær',
    'da': 'Automatisk vejr',
    'nl': 'Automatisch weer',
    'pl': 'Automatyczna pogoda',
    'cs': 'Automatické počasí',
    'hu': 'Automatikus időjárás',
    'uk': 'Автоматична погода',
    'ja': '自動天気記録',
    'ko': '자동 날씨 기록',
  });
  String get onb2Desc => _t({
    'en':
        'The app records temperature, humidity and wind at the time of attack. Smart weather-based trigger suggestions.',
    'ru':
        'Приложение фиксирует температуру, влажность и ветер в момент приступа. Умные подсказки триггеров по погоде.',
    'de':
        'Die App erfasst Temperatur, Luftfeuchtigkeit und Wind zum Zeitpunkt des Anfalls. Intelligente wetterbasierte Auslöservorschläge.',
    'fr':
        "L'appli enregistre la température, l'humidité et le vent pendant la crise. Suggestions intelligentes basées sur la météo.",
    'es':
        'La app registra temperatura, humedad y viento durante la crisis. Sugerencias inteligentes basadas en el clima.',
    'pt':
        'O app registra temperatura, umidade e vento durante a crise. Sugestões inteligentes baseadas no clima.',
    'it':
        "L'app registra temperatura, umidità e vento durante la crisi. Suggerimenti intelligenti basati sul meteo.",
    'sv':
        'Appen registrerar temperatur, luftfuktighet och vind vid attacken. Smarta väderbaserade triggerförslag.',
    'fi':
        'Sovellus tallentaa lämpötilan, kosteuden ja tuulen kohtauksen aikana. Älykkäät sääpohjaiset laukaisijaehdotukset.',
    'nb':
        'Appen registrerer temperatur, fuktighet og vind under anfallet. Smarte værbaserte utløserforslag.',
    'da':
        'Appen registrerer temperatur, luftfugtighed og vind under anfaldet. Smarte vejrbaserede udløserforslag.',
    'nl':
        'De app registreert temperatuur, vochtigheid en wind tijdens de aanval. Slimme weergebaseerde triggersuggesties.',
    'pl':
        'Aplikacja rejestruje temperaturę, wilgotność i wiatr podczas ataku. Inteligentne sugestie wyzwalaczy na podstawie pogody.',
    'cs':
        'Aplikace zaznamenává teplotu, vlhkost a vítr při záchvatu. Chytré návrhy spouštěčů na základě počasí.',
    'hu':
        'Az alkalmazás rögzíti a hőmérsékletet, páratartalmat és szelet a roham idején. Okos időjárás-alapú kiváltó javaslatok.',
    'uk':
        'Додаток фіксує температуру, вологість і вітер під час нападу. Розумні підказки тригерів за погодою.',
    'ja': 'アプリは発作時の気温、湿度、風速を記録します。天気に基づくスマートな誘因提案。',
    'ko': '앱이 발작 시 기온, 습도, 풍속을 기록합니다. 날씨 기반 스마트 유발 요인 제안.',
  });
  String get onb3Title => _t({
    'en': 'Doctor report',
    'ru': 'Отчёт для врача',
    'de': 'Arztbericht',
    'fr': 'Rapport médical',
    'es': 'Informe médico',
    'pt': 'Relatório médico',
    'it': 'Report medico',
    'sv': 'Läkarrapport',
    'fi': 'Lääkäriraportti',
    'nb': 'Legerapport',
    'da': 'Lægerapport',
    'nl': 'Doktersrapport',
    'pl': 'Raport dla lekarza',
    'cs': 'Zpráva pro lékaře',
    'hu': 'Orvosi jelentés',
    'uk': 'Звіт для лікаря',
    'ja': '医師向けレポート',
    'ko': '의사 보고서',
  });
  String get onb3Desc => _t({
    'en':
        'Generate PDF reports with charts and statistics. Show your rheumatologist the full picture.',
    'ru':
        'Создавай PDF-отчёты с графиками и статистикой. Покажи ревматологу полную картину.',
    'de':
        'Erstelle PDF-Berichte mit Diagrammen und Statistiken. Zeige deinem Rheumatologen das Gesamtbild.',
    'fr':
        'Créez des rapports PDF avec graphiques et statistiques. Montrez le tableau complet à votre rhumatologue.',
    'es':
        'Genera informes PDF con gráficos y estadísticas. Muéstrale el panorama completo a tu reumatólogo.',
    'pt':
        'Gere relatórios PDF com gráficos e estatísticas. Mostre ao seu reumatologista o quadro completo.',
    'it':
        'Genera report PDF con grafici e statistiche. Mostra al tuo reumatologo il quadro completo.',
    'sv':
        'Skapa PDF-rapporter med diagram och statistik. Visa din reumatolog hela bilden.',
    'fi':
        'Luo PDF-raportteja kaavioilla ja tilastoilla. Näytä reumatologillesi kokonaiskuva.',
    'nb':
        'Lag PDF-rapporter med diagrammer og statistikk. Vis revmatologen det fulle bildet.',
    'da':
        'Generer PDF-rapporter med diagrammer og statistik. Vis din reumatolog det fulde billede.',
    'nl':
        'Genereer PDF-rapporten met grafieken en statistieken. Toon uw reumatoloog het volledige beeld.',
    'pl':
        'Generuj raporty PDF z wykresami i statystykami. Pokaż reumatologowi pełny obraz.',
    'cs':
        'Generujte PDF zprávy s grafy a statistikami. Ukažte revmatologovi úplný obraz.',
    'hu':
        'Készítsen PDF jelentéseket diagramokkal és statisztikákkal. Mutassa meg reumatológusának a teljes képet.',
    'uk':
        'Створюйте PDF-звіти з графіками та статистикою. Покажіть ревматологу повну картину.',
    'ja': 'チャートと統計を含むPDFレポートを作成。リウマチ専門医に全体像を見せましょう。',
    'ko': '차트와 통계가 포함된 PDF 보고서를 생성하세요. 류마티스 전문의에게 전체 상황을 보여주세요.',
  });
  String get onb4Title => _t({
    'en': 'Location for weather',
    'ru': 'Геолокация для погоды',
    'de': 'Standort für Wetter',
    'fr': 'Localisation pour la météo',
    'es': 'Ubicación para el clima',
    'pt': 'Localização para o clima',
    'it': 'Posizione per il meteo',
    'sv': 'Plats för väder',
    'fi': 'Sijainti säälle',
    'nb': 'Posisjon for vær',
    'da': 'Placering for vejr',
    'nl': 'Locatie voor weer',
    'pl': 'Lokalizacja dla pogody',
    'cs': 'Poloha pro počasí',
    'hu': 'Helyadatok az időjáráshoz',
    'uk': 'Геолокація для погоди',
    'ja': '天気のための位置情報',
    'ko': '날씨를 위한 위치',
  });
  String get onb4Desc => _t({
    'en':
        'Allow location access - the app will automatically record temperature, humidity and wind during an attack. Data is not shared with third parties.',
    'ru':
        'Разрешите доступ к геолокации - приложение автоматически зафиксирует температуру, влажность и ветер в момент приступа. Данные не передаются третьим лицам.',
    'de':
        'Standortzugriff erlauben - die App erfasst automatisch Temperatur, Luftfeuchtigkeit und Wind während eines Anfalls. Daten werden nicht an Dritte weitergegeben.',
    'fr':
        "Autorisez l'accès à la localisation - l'appli enregistrera automatiquement les données météo pendant une crise. Les données ne sont pas partagées.",
    'es':
        'Permite el acceso a ubicación - la app registrará automáticamente los datos meteorológicos durante una crisis. Los datos no se comparten con terceros.',
    'pt':
        'Permita acesso à localização - o app registrará automaticamente os dados climáticos durante uma crise. Os dados não são compartilhados com terceiros.',
    'it':
        "Consenti l'accesso alla posizione - l'app registrerà automaticamente i dati meteo durante una crisi. I dati non vengono condivisi.",
    'sv':
        'Tillåt platsåtkomst - appen registrerar automatiskt väderdata under en attack. Data delas inte med tredje part.',
    'fi':
        'Salli sijainnin käyttö - sovellus tallentaa automaattisesti säätiedot kohtauksen aikana. Tietoja ei jaeta kolmansille osapuolille.',
    'nb':
        'Tillat posisjonstilgang - appen registrerer automatisk værdata under et anfall. Data deles ikke med tredjeparter.',
    'da':
        'Tillad placeringsadgang - appen registrerer automatisk vejrdata under et anfald. Data deles ikke med tredjeparter.',
    'nl':
        'Sta locatietoegang toe - de app registreert automatisch weergegevens tijdens een aanval. Gegevens worden niet gedeeld met derden.',
    'pl':
        'Zezwól na dostęp do lokalizacji - aplikacja automatycznie zapisze dane pogodowe podczas ataku. Dane nie są udostępniane osobom trzecim.',
    'cs':
        'Povolte přístup k poloze - aplikace automaticky zaznamená počasí během záchvatu. Data nejsou sdílena s třetími stranami.',
    'hu':
        'Engedélyezze a helyhozzáférést - az alkalmazás automatikusan rögzíti az időjárási adatokat roham közben. Az adatok nem kerülnek megosztásra.',
    'uk':
        'Дозвольте доступ до геолокації - додаток автоматично зафіксує погодні дані під час нападу. Дані не передаються третім особам.',
    'ja': '位置情報へのアクセスを許可してください。発作時の気象データを自動記録します。データは第三者と共有されません。',
    'ko': '위치 접근을 허용하세요. 발작 시 기상 데이터를 자동으로 기록합니다. 데이터는 제3자와 공유되지 않습니다.',
  });
  String get onb5Title => _t({
    'en': 'Reminders',
    'ru': 'Напоминания',
    'de': 'Erinnerungen',
    'fr': 'Rappels',
    'es': 'Recordatorios',
    'pt': 'Lembretes',
    'it': 'Promemoria',
    'sv': 'Påminnelser',
    'fi': 'Muistutukset',
    'nb': 'Påminnelser',
    'da': 'Påmindelser',
    'nl': 'Herinneringen',
    'pl': 'Przypomnienia',
    'cs': 'Připomínky',
    'hu': 'Emlékeztetők',
    'uk': 'Нагадування',
    'ja': 'リマインダー',
    'ko': '알림',
  });
  String get onb5Desc => _t({
    'en':
        'A daily 12:30 reminder helps you never miss logging an attack. Can be turned off anytime.',
    'ru':
        'Ежедневное напоминание в 12:30 поможет не забыть записать приступ. Можно отключить в любой момент.',
    'de':
        'Eine tägliche Erinnerung um 12:30 Uhr hilft dir, keinen Anfall zu vergessen. Jederzeit deaktivierbar.',
    'fr':
        'Un rappel quotidien à 12h30 pour ne jamais oublier. Désactivable à tout moment.',
    'es':
        'Un recordatorio diario a las 12:30 te ayuda a no olvidar. Se puede desactivar en cualquier momento.',
    'pt':
        'Um lembrete diário às 12:30 ajuda a não esquecer. Pode ser desativado a qualquer momento.',
    'it':
        'Un promemoria quotidiano alle 12:30 aiuta a non dimenticare. Disattivabile in qualsiasi momento.',
    'sv':
        'En daglig påminnelse kl. 12:30 hjälper dig att aldrig missa. Kan stängas av när som helst.',
    'fi':
        'Päivittäinen muistutus klo 12:30 auttaa muistamaan. Voidaan kytkeä pois milloin tahansa.',
    'nb':
        'En daglig påminnelse kl. 12:30 hjelper deg å huske. Kan slås av når som helst.',
    'da':
        'En daglig påmindelse kl. 12:30 hjælper dig med at huske. Kan slås fra når som helst.',
    'nl':
        'Een dagelijkse herinnering om 12:30 helpt u niets te missen. Altijd uit te schakelen.',
    'pl':
        'Codzienne przypomnienie o 12:30 pomoże nie zapomnieć. Można wyłączyć w dowolnym momencie.',
    'cs': 'Denní připomínka ve 12:30 pomůže nezapomenout. Lze kdykoli vypnout.',
    'hu':
        'A napi 12:30-as emlékeztető segít nem felejteni. Bármikor kikapcsolható.',
    'uk':
        'Щоденне нагадування о 12:30 допоможе не забути. Можна вимкнути будь-коли.',
    'ja': '毎日12:30のリマインダーで記録を忘れません。いつでもオフにできます。',
    'ko': '매일 12:30 알림으로 기록을 잊지 마세요. 언제든 끌 수 있습니다.',
  });
  String get enableReminders => _t({
    'en': 'Enable reminders',
    'ru': 'Включить напоминания',
    'de': 'Erinnerungen aktivieren',
    'fr': 'Activer les rappels',
    'es': 'Activar recordatorios',
    'pt': 'Ativar lembretes',
    'it': 'Attiva promemoria',
    'sv': 'Aktivera påminnelser',
    'fi': 'Ota muistutukset käyttöön',
    'nb': 'Aktiver påminnelser',
    'da': 'Aktiver påmindelser',
    'nl': 'Herinneringen inschakelen',
    'pl': 'Włącz przypomnienia',
    'cs': 'Povolit připomínky',
    'hu': 'Emlékeztetők bekapcsolása',
    'uk': 'Увімкнути нагадування',
    'ja': 'リマインダーを有効にする',
    'ko': '알림 활성화',
  });
  String get allowLocation => _t({
    'en': 'Allow location',
    'ru': 'Разрешить геолокацию',
    'de': 'Standort erlauben',
    'fr': 'Autoriser la localisation',
    'es': 'Permitir ubicación',
    'pt': 'Permitir localização',
    'it': 'Consenti posizione',
    'sv': 'Tillåt plats',
    'fi': 'Salli sijainti',
    'nb': 'Tillat posisjon',
    'da': 'Tillad placering',
    'nl': 'Locatie toestaan',
    'pl': 'Zezwól na lokalizację',
    'cs': 'Povolit polohu',
    'hu': 'Helyadat engedélyezése',
    'uk': 'Дозволити геолокацію',
    'ja': '位置情報を許可',
    'ko': '위치 허용',
  });

  // === История ===
  String get attacksThisWeek => _t({
    'en': 'Attacks this week',
    'ru': 'Приступы за неделю',
    'de': 'Anfälle diese Woche',
    'fr': 'Crises cette semaine',
    'es': 'Crisis esta semana',
    'pt': 'Crises esta semana',
    'it': 'Crisi questa settimana',
    'sv': 'Attacker denna vecka',
    'fi': 'Kohtaukset tällä viikolla',
    'nb': 'Anfall denne uken',
    'da': 'Anfald denne uge',
    'nl': 'Aanvallen deze week',
    'pl': 'Ataki w tym tygodniu',
    'cs': 'Záchvaty tento týden',
    'hu': 'Rohamok ezen a héten',
    'uk': 'Напади цього тижня',
    'ja': '今週の発作',
    'ko': '이번 주 발작',
  });
  String get statistics => _t({
    'en': 'Statistics',
    'ru': 'Статистика',
    'de': 'Statistik',
    'fr': 'Statistiques',
    'es': 'Estadísticas',
    'pt': 'Estatísticas',
    'it': 'Statistiche',
    'sv': 'Statistik',
    'fi': 'Tilastot',
    'nb': 'Statistikk',
    'da': 'Statistik',
    'nl': 'Statistieken',
    'pl': 'Statystyki',
    'cs': 'Statistiky',
    'hu': 'Statisztikák',
    'uk': 'Статистика',
    'ja': '統計',
    'ko': '통계',
  });
  String get avgWeekSeverity => _t({
    'en': 'Avg weekly severity',
    'ru': 'Средн. тяжесть за неделю',
    'de': 'Ø Schwere pro Woche',
    'fr': 'Sévérité moy. hebdo',
    'es': 'Gravedad prom. semanal',
    'pt': 'Gravidade média semanal',
    'it': 'Gravità media settimanale',
    'sv': 'Snitt svårighetsgrad/vecka',
    'fi': 'Keskim. vakavuus/viikko',
    'nb': 'Sn. alvorlighetsgrad/uke',
    'da': 'Gns. sværhedsgrad/uge',
    'nl': 'Gem. ernst/week',
    'pl': 'Śr. ciężkość/tydzień',
    'cs': 'Prům. závažnost/týden',
    'hu': 'Átl. súlyosság/hét',
    'uk': 'Сер. тяжкість/тиждень',
    'ja': '平均週間重症度',
    'ko': '주간 평균 심각도',
  });
  String get avgMonthSeverity => _t({
    'en': 'Avg monthly severity',
    'ru': 'Средн. тяжесть за месяц',
    'de': 'Ø Schwere pro Monat',
    'fr': 'Sévérité moy. mensuelle',
    'es': 'Gravedad prom. mensual',
    'pt': 'Gravidade média mensal',
    'it': 'Gravità media mensile',
    'sv': 'Snitt svårighetsgrad/månad',
    'fi': 'Keskim. vakavuus/kuukausi',
    'nb': 'Sn. alvorlighetsgrad/mnd',
    'da': 'Gns. sværhedsgrad/mnd',
    'nl': 'Gem. ernst/maand',
    'pl': 'Śr. ciężkość/miesiąc',
    'cs': 'Prům. závažnost/měsíc',
    'hu': 'Átl. súlyosság/hó',
    'uk': 'Сер. тяжкість/місяць',
    'ja': '平均月間重症度',
    'ko': '월간 평균 심각도',
  });
  String get totalAttacks => _t({
    'en': 'Total attacks',
    'ru': 'Всего приступов',
    'de': 'Anfälle insgesamt',
    'fr': 'Total des crises',
    'es': 'Total de crisis',
    'pt': 'Total de crises',
    'it': 'Totale crisi',
    'sv': 'Totalt attacker',
    'fi': 'Kohtauksia yhteensä',
    'nb': 'Totalt anfall',
    'da': 'Anfald i alt',
    'nl': 'Totaal aanvallen',
    'pl': 'Łącznie ataków',
    'cs': 'Záchvatů celkem',
    'hu': 'Összes roham',
    'uk': 'Всього нападів',
    'ja': '発作合計',
    'ko': '총 발작 수',
  });
  String get allAttacks => _t({
    'en': 'All attacks',
    'ru': 'Все приступы',
    'de': 'Alle Anfälle',
    'fr': 'Toutes les crises',
    'es': 'Todas las crisis',
    'pt': 'Todas as crises',
    'it': 'Tutte le crisi',
    'sv': 'Alla attacker',
    'fi': 'Kaikki kohtaukset',
    'nb': 'Alle anfall',
    'da': 'Alle anfald',
    'nl': 'Alle aanvallen',
    'pl': 'Wszystkie ataki',
    'cs': 'Všechny záchvaty',
    'hu': 'Összes roham',
    'uk': 'Усі напади',
    'ja': 'すべての発作',
    'ko': '모든 발작',
  });
  String get noAttacksYet => _t({
    'en': 'No attacks yet.',
    'ru': 'Приступов пока нет.',
    'de': 'Noch keine Anfälle.',
    'fr': 'Aucune crise pour le moment.',
    'es': 'Aún no hay crisis.',
    'pt': 'Nenhuma crise ainda.',
    'it': 'Nessuna crisi ancora.',
    'sv': 'Inga attacker ännu.',
    'fi': 'Ei vielä kohtauksia.',
    'nb': 'Ingen anfall ennå.',
    'da': 'Ingen anfald endnu.',
    'nl': 'Nog geen aanvallen.',
    'pl': 'Brak ataków.',
    'cs': 'Zatím žádné záchvaty.',
    'hu': 'Még nincsenek rohamok.',
    'uk': 'Нападів ще немає.',
    'ja': 'まだ発作はありません。',
    'ko': '아직 발작이 없습니다.',
  });

  // === О приложении ===
  String get aboutTitle => _t({
    'en': 'About',
    'ru': 'О приложении',
    'de': 'Über',
    'fr': 'À propos',
    'es': 'Acerca de',
    'pt': 'Sobre',
    'it': 'Info',
    'sv': 'Om',
    'fi': 'Tietoja',
    'nb': 'Om',
    'da': 'Om',
    'nl': 'Over',
    'pl': 'O aplikacji',
    'cs': 'O aplikaci',
    'hu': 'Névjegy',
    'uk': 'Про додаток',
    'ja': 'アプリについて',
    'ko': '앱 정보',
  });
  String get version => _t({
    'en': 'Version',
    'ru': 'Версия',
    'de': 'Version',
    'fr': 'Version',
    'es': 'Versión',
    'pt': 'Versão',
    'it': 'Versione',
    'sv': 'Version',
    'fi': 'Versio',
    'nb': 'Versjon',
    'da': 'Version',
    'nl': 'Versie',
    'pl': 'Wersja',
    'cs': 'Verze',
    'hu': 'Verzió',
    'uk': 'Версія',
    'ja': 'バージョン',
    'ko': '버전',
  });
  String get medicalDisclaimer => _t({
    'en': 'Medical disclaimer',
    'ru': 'Медицинский дисклеймер',
    'de': 'Medizinischer Haftungsausschluss',
    'fr': 'Avertissement médical',
    'es': 'Aviso médico',
    'pt': 'Aviso médico',
    'it': 'Disclaimer medico',
    'sv': 'Medicinsk friskrivning',
    'fi': 'Lääketieteellinen vastuuvapauslauseke',
    'nb': 'Medisinsk ansvarsfraskrivelse',
    'da': 'Medicinsk ansvarsfraskrivelse',
    'nl': 'Medische disclaimer',
    'pl': 'Zastrzeżenie medyczne',
    'cs': 'Lékařské prohlášení',
    'hu': 'Orvosi nyilatkozat',
    'uk': 'Медичний дисклеймер',
    'ja': '医療に関する免責事項',
    'ko': '의료 면책 조항',
  });
  String get privacyPolicy => _t({
    'en': 'Privacy policy',
    'ru': 'Политика конфиденциальности',
    'de': 'Datenschutzrichtlinie',
    'fr': 'Politique de confidentialité',
    'es': 'Política de privacidad',
    'pt': 'Política de privacidade',
    'it': 'Informativa sulla privacy',
    'sv': 'Integritetspolicy',
    'fi': 'Tietosuojakäytäntö',
    'nb': 'Personvernregler',
    'da': 'Privatlivspolitik',
    'nl': 'Privacybeleid',
    'pl': 'Polityka prywatności',
    'cs': 'Zásady ochrany osobních údajů',
    'hu': 'Adatvédelmi irányelvek',
    'uk': 'Політика конфіденційності',
    'ja': 'プライバシーポリシー',
    'ko': '개인정보 처리방침',
  });
  String get yourRights => _t({
    'en': 'Your rights',
    'ru': 'Ваши права',
    'de': 'Ihre Rechte',
    'fr': 'Vos droits',
    'es': 'Sus derechos',
    'pt': 'Seus direitos',
    'it': 'I tuoi diritti',
    'sv': 'Dina rättigheter',
    'fi': 'Oikeutesi',
    'nb': 'Dine rettigheter',
    'da': 'Dine rettigheder',
    'nl': 'Uw rechten',
    'pl': 'Twoje prawa',
    'cs': 'Vaše práva',
    'hu': 'Az Ön jogai',
    'uk': 'Ваші права',
    'ja': 'あなたの権利',
    'ko': '귀하의 권리',
  });
  String get reminders => _t({
    'en': 'Reminders',
    'ru': 'Напоминания',
    'de': 'Erinnerungen',
    'fr': 'Rappels',
    'es': 'Recordatorios',
    'pt': 'Lembretes',
    'it': 'Promemoria',
    'sv': 'Påminnelser',
    'fi': 'Muistutukset',
    'nb': 'Påminnelser',
    'da': 'Påmindelser',
    'nl': 'Herinneringen',
    'pl': 'Przypomnienia',
    'cs': 'Připomínky',
    'hu': 'Emlékeztetők',
    'uk': 'Нагадування',
    'ja': 'リマインダー',
    'ko': '알림',
  });
  String get feedback => _t({
    'en': 'Feedback',
    'ru': 'Обратная связь',
    'de': 'Feedback',
    'fr': 'Retour',
    'es': 'Comentarios',
    'pt': 'Feedback',
    'it': 'Feedback',
    'sv': 'Feedback',
    'fi': 'Palaute',
    'nb': 'Tilbakemelding',
    'da': 'Feedback',
    'nl': 'Feedback',
    'pl': 'Opinia',
    'cs': 'Zpětná vazba',
    'hu': 'Visszajelzés',
    'uk': "Зворотний зв'язок",
    'ja': 'フィードバック',
    'ko': '피드백',
  });
  String get deleteAttackQuestion => _t({
    'en': 'Delete attack?',
    'ru': 'Удалить приступ?',
    'de': 'Anfall löschen?',
    'fr': 'Supprimer la crise ?',
    'es': '¿Eliminar crisis?',
    'pt': 'Excluir crise?',
    'it': 'Eliminare la crisi?',
    'sv': 'Radera attack?',
    'fi': 'Poista kohtaus?',
    'nb': 'Slette anfall?',
    'da': 'Slet anfald?',
    'nl': 'Aanval verwijderen?',
    'pl': 'Usunąć atak?',
    'cs': 'Smazat záchvat?',
    'hu': 'Roham törlése?',
    'uk': 'Видалити напад?',
    'ja': '発作を削除しますか？',
    'ko': '발작을 삭제하시겠습니까?',
  });
  String get enableGeoLocation => _t({
    'en': 'Enable location for automatic weather',
    'ru': 'Включите геолокацию для автозаполнения погоды',
    'de': 'Standort für automatisches Wetter aktivieren',
    'fr': 'Activez la localisation pour la météo automatique',
    'es': 'Activa la ubicación para el clima automático',
    'pt': 'Ative a localização para o clima automático',
    'it': 'Attiva la posizione per il meteo automatico',
    'sv': 'Aktivera plats för automatiskt väder',
    'fi': 'Ota sijainti käyttöön automaattiselle säälle',
    'nb': 'Aktiver posisjon for automatisk vær',
    'da': 'Aktiver placering for automatisk vejr',
    'nl': 'Schakel locatie in voor automatisch weer',
    'pl': 'Włącz lokalizację dla automatycznej pogody',
    'cs': 'Povolte polohu pro automatické počasí',
    'hu': 'Engedélyezze a helyadatokat az automatikus időjáráshoz',
    'uk': 'Увімкніть геолокацію для автоматичної погоди',
    'ja': '自動天気記録のために位置情報を有効にしてください',
    'ko': '자동 날씨 기록을 위해 위치를 활성화하세요',
  });

  // === Отчёт для врача ===
  String get reportTitle => _t({
    'en': 'Doctor report',
    'ru': 'Отчёт для врача',
    'de': 'Arztbericht',
    'fr': 'Rapport médical',
    'es': 'Informe médico',
    'pt': 'Relatório médico',
    'it': 'Report medico',
    'sv': 'Läkarrapport',
    'fi': 'Lääkäriraportti',
    'nb': 'Legerapport',
    'da': 'Lægerapport',
    'nl': 'Doktersrapport',
    'pl': 'Raport dla lekarza',
    'cs': 'Zpráva pro lékaře',
    'hu': 'Orvosi jelentés',
    'uk': 'Звіт для лікаря',
    'ja': '医師向けレポート',
    'ko': '의사 보고서',
  });
  String get createPdfReport => _t({
    'en': 'Create PDF report',
    'ru': 'Создать PDF отчёт',
    'de': 'PDF-Bericht erstellen',
    'fr': 'Créer un rapport PDF',
    'es': 'Crear informe PDF',
    'pt': 'Criar relatório PDF',
    'it': 'Crea report PDF',
    'sv': 'Skapa PDF-rapport',
    'fi': 'Luo PDF-raportti',
    'nb': 'Lag PDF-rapport',
    'da': 'Opret PDF-rapport',
    'nl': 'PDF-rapport maken',
    'pl': 'Utwórz raport PDF',
    'cs': 'Vytvořit PDF zprávu',
    'hu': 'PDF jelentés létrehozása',
    'uk': 'Створити PDF звіт',
    'ja': 'PDFレポートを作成',
    'ko': 'PDF 보고서 만들기',
  });
  String get reportDescription => _t({
    'en':
        "Create a detailed Raynaud's attack report for your doctor. Includes attack log, trigger analysis and weather correlation.",
    'ru':
        'Создай подробный отчёт о приступах Рейно для лечащего врача. Включает журнал приступов, анализ триггеров и корреляцию с погодой.',
    'de':
        'Erstelle einen detaillierten Raynaud-Bericht für deinen Arzt. Enthält Anfallprotokoll, Auslöseranalyse und Wetterkorrelation.',
    'fr':
        'Créez un rapport détaillé des crises de Raynaud pour votre médecin. Journal des crises, analyse des déclencheurs et corrélation météo.',
    'es':
        'Crea un informe detallado de crisis de Raynaud para tu médico. Registro de crisis, análisis de desencadenantes y correlación climática.',
    'pt':
        'Crie um relatório detalhado de crises de Raynaud para seu médico. Registro de crises, análise de gatilhos e correlação climática.',
    'it':
        'Crea un report dettagliato delle crisi di Raynaud per il tuo medico. Registro crisi, analisi fattori scatenanti e correlazione meteo.',
    'sv':
        'Skapa en detaljerad Raynaud-rapport till din läkare. Attacklogg, triggeranalys och väderkorrelation.',
    'fi':
        'Luo yksityiskohtainen Raynaud-raportti lääkärillesi. Kohtausloki, laukaisijaanalyysi ja sääkorrelaatio.',
    'nb':
        'Lag en detaljert Raynaud-rapport til legen din. Anfallslogg, utløseranalyse og værkorrelasjon.',
    'da':
        'Opret en detaljeret Raynaud-rapport til din læge. Anfaldslog, udløseranalyse og vejrkorrelation.',
    'nl':
        'Maak een gedetailleerd Raynaud-rapport voor uw arts. Aanvallog, triggeranalyse en weercorrelatie.',
    'pl':
        'Utwórz szczegółowy raport o atakach Raynauda dla lekarza. Dziennik ataków, analiza wyzwalaczy i korelacja z pogodą.',
    'cs':
        'Vytvořte podrobnou zprávu o záchvatech Raynaudova syndromu pro lékaře. Protokol záchvatů, analýza spouštěčů a korelace s počasím.',
    'hu':
        'Készítsen részletes Raynaud-jelentést orvosának. Rohamnapló, kiváltó elemzés és időjárási korreláció.',
    'uk':
        'Створіть детальний звіт про напади Рейно для лікаря. Журнал нападів, аналіз тригерів та кореляція з погодою.',
    'ja': 'レイノー発作の詳細レポートを医師向けに作成します。発作ログ、誘因分析、気象相関を含みます。',
    'ko': '의사를 위한 상세한 레이노 발작 보고서를 만듭니다. 발작 로그, 유발 요인 분석, 날씨 상관관계를 포함합니다.',
  });
  String get period => _t({
    'en': 'Period',
    'ru': 'Период',
    'de': 'Zeitraum',
    'fr': 'Période',
    'es': 'Período',
    'pt': 'Período',
    'it': 'Periodo',
    'sv': 'Period',
    'fi': 'Ajanjakso',
    'nb': 'Periode',
    'da': 'Periode',
    'nl': 'Periode',
    'pl': 'Okres',
    'cs': 'Období',
    'hu': 'Időszak',
    'uk': 'Період',
    'ja': '期間',
    'ko': '기간',
  });
  String attacksInPeriod(int count) => _t({
    'en': '$count attacks in this period',
    'ru': '$count приступов за этот период',
    'de': '$count Anfälle in diesem Zeitraum',
    'fr': '$count crises sur cette période',
    'es': '$count crisis en este período',
    'pt': '$count crises neste período',
    'it': '$count crisi in questo periodo',
    'sv': '$count attacker under denna period',
    'fi': '$count kohtausta tällä jaksolla',
    'nb': '$count anfall i denne perioden',
    'da': '$count anfald i denne periode',
    'nl': '$count aanvallen in deze periode',
    'pl': '$count ataków w tym okresie',
    'cs': '$count záchvatů v tomto období',
    'hu': '$count roham ebben az időszakban',
    'uk': '$count нападів за цей період',
    'ja': 'この期間の発作: $count回',
    'ko': '이 기간의 발작: $count회',
  });
  String get createAndSharePdf => _t({
    'en': 'Create & share PDF',
    'ru': 'Создать и отправить PDF',
    'de': 'PDF erstellen & teilen',
    'fr': 'Créer et partager le PDF',
    'es': 'Crear y compartir PDF',
    'pt': 'Criar e compartilhar PDF',
    'it': 'Crea e condividi PDF',
    'sv': 'Skapa & dela PDF',
    'fi': 'Luo ja jaa PDF',
    'nb': 'Lag og del PDF',
    'da': 'Opret og del PDF',
    'nl': 'PDF maken & delen',
    'pl': 'Utwórz i udostępnij PDF',
    'cs': 'Vytvořit a sdílet PDF',
    'hu': 'PDF létrehozása és megosztása',
    'uk': 'Створити та надіслати PDF',
    'ja': 'PDFを作成・共有',
    'ko': 'PDF 생성 및 공유',
  });
  String get noAttacksInPeriod => _t({
    'en': 'No attacks in selected period',
    'ru': 'Нет приступов за выбранный период',
    'de': 'Keine Anfälle im gewählten Zeitraum',
    'fr': 'Aucune crise dans la période sélectionnée',
    'es': 'Sin crisis en el período seleccionado',
    'pt': 'Nenhuma crise no período selecionado',
    'it': 'Nessuna crisi nel periodo selezionato',
    'sv': 'Inga attacker under vald period',
    'fi': 'Ei kohtauksia valitulla jaksolla',
    'nb': 'Ingen anfall i valgt periode',
    'da': 'Ingen anfald i den valgte periode',
    'nl': 'Geen aanvallen in de geselecteerde periode',
    'pl': 'Brak ataków w wybranym okresie',
    'cs': 'Žádné záchvaty ve vybraném období',
    'hu': 'Nincs roham a kiválasztott időszakban',
    'uk': 'Немає нападів за обраний період',
    'ja': '選択期間に発作はありません',
    'ko': '선택한 기간에 발작이 없습니다',
  });
  String periodDays(int days) => _t({
    'en': '$days days',
    'ru': '$days дней',
    'de': '$days Tage',
    'fr': '$days jours',
    'es': '$days días',
    'pt': '$days dias',
    'it': '$days giorni',
    'sv': '$days dagar',
    'fi': '$days päivää',
    'nb': '$days dager',
    'da': '$days dage',
    'nl': '$days dagen',
    'pl': '$days dni',
    'cs': '$days dní',
    'hu': '$days nap',
    'uk': '$days днів',
    'ja': '$days日間',
    'ko': '$days일',
  });

  // === Погода / единицы ===
  String windMs(String speed) => _t({
    'en': 'Wind $speed m/s',
    'ru': 'Ветер $speed м/с',
    'de': 'Wind $speed m/s',
    'fr': 'Vent $speed m/s',
    'es': 'Viento $speed m/s',
    'pt': 'Vento $speed m/s',
    'it': 'Vento $speed m/s',
    'sv': 'Vind $speed m/s',
    'fi': 'Tuuli $speed m/s',
    'nb': 'Vind $speed m/s',
    'da': 'Vind $speed m/s',
    'nl': 'Wind $speed m/s',
    'pl': 'Wiatr $speed m/s',
    'cs': 'Vítr $speed m/s',
    'hu': 'Szél $speed m/s',
    'uk': 'Вітер $speed м/с',
    'ja': '風速 $speed m/s',
    'ko': '바람 $speed m/s',
  });
  String humidity(String value) => _t({
    'en': 'Humidity $value%',
    'ru': 'Влажн. $value%',
    'de': 'Feuchte $value%',
    'fr': 'Humid. $value%',
    'es': 'Humedad $value%',
    'pt': 'Umidade $value%',
    'it': 'Umidità $value%',
    'sv': 'Fuktighet $value%',
    'fi': 'Kosteus $value%',
    'nb': 'Fuktighet $value%',
    'da': 'Luftfugtighed $value%',
    'nl': 'Vochtigheid $value%',
    'pl': 'Wilgotn. $value%',
    'cs': 'Vlhkost $value%',
    'hu': 'Páratartalom $value%',
    'uk': 'Вологість $value%',
    'ja': '湿度 $value%',
    'ko': '습도 $value%',
  });
  String minutesAgo(int min) => _t({
    'en': '${min}m ago',
    'ru': '$min мин назад',
    'de': 'vor $min Min.',
    'fr': 'il y a $min min',
    'es': 'hace $min min',
    'pt': '$min min atrás',
    'it': '$min min fa',
    'sv': '$min min sedan',
    'fi': '$min min sitten',
    'nb': '$min min siden',
    'da': '$min min siden',
    'nl': '$min min geleden',
    'pl': '$min min temu',
    'cs': 'před $min min',
    'hu': '$min perccel ezelőtt',
    'uk': '$min хв тому',
    'ja': '$min分前',
    'ko': '$min분 전',
  });
  String get min => _t({
    'en': 'min',
    'ru': 'мин',
    'de': 'Min.',
    'fr': 'min',
    'es': 'min',
    'pt': 'min',
    'it': 'min',
    'sv': 'min',
    'fi': 'min',
    'nb': 'min',
    'da': 'min',
    'nl': 'min',
    'pl': 'min',
    'cs': 'min',
    'hu': 'perc',
    'uk': 'хв',
    'ja': '分',
    'ko': '분',
  });
  String get photo => _t({
    'en': 'Photo',
    'ru': 'Фото',
    'de': 'Foto',
    'fr': 'Photo',
    'es': 'Foto',
    'pt': 'Foto',
    'it': 'Foto',
    'sv': 'Foto',
    'fi': 'Kuva',
    'nb': 'Bilde',
    'da': 'Foto',
    'nl': 'Foto',
    'pl': 'Zdjęcie',
    'cs': 'Foto',
    'hu': 'Fotó',
    'uk': 'Фото',
    'ja': '写真',
    'ko': '사진',
  });

  // === Accessibility ===
  String get a11ySeveritySlider => _t({
    'en': 'Severity scale from 0 to 10',
    'ru': 'Шкала тяжести от 0 до 10',
    'de': 'Schweregradskala von 0 bis 10',
    'fr': 'Échelle de sévérité de 0 à 10',
    'es': 'Escala de gravedad de 0 a 10',
    'pt': 'Escala de gravidade de 0 a 10',
    'it': 'Scala di gravità da 0 a 10',
    'sv': 'Svårighetsskala från 0 till 10',
    'fi': 'Vakavuusasteikko 0-10',
    'nb': 'Alvorlighetsskala fra 0 til 10',
    'da': 'Sværhedsskala fra 0 til 10',
    'nl': 'Ernstschaal van 0 tot 10',
    'pl': 'Skala ciężkości od 0 do 10',
    'cs': 'Stupnice závažnosti od 0 do 10',
    'hu': 'Súlyossági skála 0-tól 10-ig',
    'uk': 'Шкала тяжкості від 0 до 10',
    'ja': '重症度スケール 0〜10',
    'ko': '심각도 척도 0~10',
  });
  String get a11yDurationSlider => _t({
    'en': 'Duration in minutes',
    'ru': 'Длительность в минутах',
    'de': 'Dauer in Minuten',
    'fr': 'Durée en minutes',
    'es': 'Duración en minutos',
    'pt': 'Duração em minutos',
    'it': 'Durata in minuti',
    'sv': 'Varaktighet i minuter',
    'fi': 'Kesto minuutteina',
    'nb': 'Varighet i minutter',
    'da': 'Varighed i minutter',
    'nl': 'Duur in minuten',
    'pl': 'Czas trwania w minutach',
    'cs': 'Trvání v minutách',
    'hu': 'Időtartam percben',
    'uk': 'Тривалість у хвилинах',
    'ja': '持続時間（分）',
    'ko': '지속 시간(분)',
  });
  String a11yFingerButton(String finger) => _t({
    'en': 'Finger: $finger',
    'ru': 'Палец: $finger',
    'de': 'Finger: $finger',
    'fr': 'Doigt : $finger',
    'es': 'Dedo: $finger',
    'pt': 'Dedo: $finger',
    'it': 'Dito: $finger',
    'sv': 'Finger: $finger',
    'fi': 'Sormi: $finger',
    'nb': 'Finger: $finger',
    'da': 'Finger: $finger',
    'nl': 'Vinger: $finger',
    'pl': 'Palec: $finger',
    'cs': 'Prst: $finger',
    'hu': 'Ujj: $finger',
    'uk': 'Палець: $finger',
    'ja': '指: $finger',
    'ko': '손가락: $finger',
  });
  String a11yTriggerChip(String trigger, bool selected) {
    final state = selected
        ? _t({
            'en': 'selected',
            'ru': 'выбран',
            'de': 'ausgewählt',
            'fr': 'sélectionné',
            'es': 'seleccionado',
            'pt': 'selecionado',
            'it': 'selezionato',
            'sv': 'vald',
            'fi': 'valittu',
            'nb': 'valgt',
            'da': 'valgt',
            'nl': 'geselecteerd',
            'pl': 'wybrany',
            'cs': 'vybráno',
            'hu': 'kiválasztva',
            'uk': 'обрано',
            'ja': '選択済み',
            'ko': '선택됨',
          })
        : _t({
            'en': 'not selected',
            'ru': 'не выбран',
            'de': 'nicht ausgewählt',
            'fr': 'non sélectionné',
            'es': 'no seleccionado',
            'pt': 'não selecionado',
            'it': 'non selezionato',
            'sv': 'inte vald',
            'fi': 'ei valittu',
            'nb': 'ikke valgt',
            'da': 'ikke valgt',
            'nl': 'niet geselecteerd',
            'pl': 'nie wybrany',
            'cs': 'nevybráno',
            'hu': 'nem kiválasztva',
            'uk': 'не обрано',
            'ja': '未選択',
            'ko': '선택 안 됨',
          });
    return '$trigger, $state';
  }

  String get a11yAddAttack => _t({
    'en': 'Record new attack',
    'ru': 'Записать новый приступ',
    'de': 'Neuen Anfall erfassen',
    'fr': 'Enregistrer une nouvelle crise',
    'es': 'Registrar nueva crisis',
    'pt': 'Registrar nova crise',
    'it': 'Registra nuova crisi',
    'sv': 'Registrera ny attack',
    'fi': 'Kirjaa uusi kohtaus',
    'nb': 'Registrer nytt anfall',
    'da': 'Registrer nyt anfald',
    'nl': 'Nieuwe aanval registreren',
    'pl': 'Zapisz nowy atak',
    'cs': 'Zaznamenat nový záchvat',
    'hu': 'Új roham rögzítése',
    'uk': 'Записати новий напад',
    'ja': '新しい発作を記録',
    'ko': '새 발작 기록',
  });
  String get a11yDeleteAttack => _t({
    'en': 'Delete attack',
    'ru': 'Удалить приступ',
    'de': 'Anfall löschen',
    'fr': 'Supprimer la crise',
    'es': 'Eliminar crisis',
    'pt': 'Excluir crise',
    'it': 'Elimina crisi',
    'sv': 'Radera attack',
    'fi': 'Poista kohtaus',
    'nb': 'Slett anfall',
    'da': 'Slet anfald',
    'nl': 'Aanval verwijderen',
    'pl': 'Usuń atak',
    'cs': 'Smazat záchvat',
    'hu': 'Roham törlése',
    'uk': 'Видалити напад',
    'ja': '発作を削除',
    'ko': '발작 삭제',
  });
  String get a11yEditAttack => _t({
    'en': 'Edit attack',
    'ru': 'Редактировать приступ',
    'de': 'Anfall bearbeiten',
    'fr': 'Modifier la crise',
    'es': 'Editar crisis',
    'pt': 'Editar crise',
    'it': 'Modifica crisi',
    'sv': 'Redigera attack',
    'fi': 'Muokkaa kohtausta',
    'nb': 'Rediger anfall',
    'da': 'Rediger anfald',
    'nl': 'Aanval bewerken',
    'pl': 'Edytuj atak',
    'cs': 'Upravit záchvat',
    'hu': 'Roham szerkesztése',
    'uk': 'Редагувати напад',
    'ja': '発作を編集',
    'ko': '발작 편집',
  });
  String a11ySeverityValue(int value) => _t({
    'en': 'Severity $value of 10',
    'ru': 'Тяжесть $value из 10',
    'de': 'Schweregrad $value von 10',
    'fr': 'Sévérité $value sur 10',
    'es': 'Gravedad $value de 10',
    'pt': 'Gravidade $value de 10',
    'it': 'Gravità $value su 10',
    'sv': 'Svårighetsgrad $value av 10',
    'fi': 'Vakavuus $value/10',
    'nb': 'Alvorlighetsgrad $value av 10',
    'da': 'Sværhedsgrad $value af 10',
    'nl': 'Ernst $value van 10',
    'pl': 'Ciężkość $value z 10',
    'cs': 'Závažnost $value z 10',
    'hu': 'Súlyosság $value/10',
    'uk': 'Тяжкість $value з 10',
    'ja': '重症度 $value/10',
    'ko': '심각도 $value/10',
  });
  String a11yWeatherInfo(String temp, String wind, String humid) => _t({
    'en': 'Weather: $temp°C, wind $wind m/s, humidity $humid%',
    'ru': 'Погода: $temp°C, ветер $wind м/с, влажность $humid%',
    'de': 'Wetter: $temp°C, Wind $wind m/s, Luftfeuchtigkeit $humid%',
    'fr': 'Météo : $temp°C, vent $wind m/s, humidité $humid%',
    'es': 'Clima: $temp°C, viento $wind m/s, humedad $humid%',
    'pt': 'Clima: $temp°C, vento $wind m/s, umidade $humid%',
    'it': 'Meteo: $temp°C, vento $wind m/s, umidità $humid%',
    'sv': 'Väder: $temp°C, vind $wind m/s, fuktighet $humid%',
    'fi': 'Sää: $temp°C, tuuli $wind m/s, kosteus $humid%',
    'nb': 'Vær: $temp°C, vind $wind m/s, fuktighet $humid%',
    'da': 'Vejr: $temp°C, vind $wind m/s, luftfugtighed $humid%',
    'nl': 'Weer: $temp°C, wind $wind m/s, vochtigheid $humid%',
    'pl': 'Pogoda: $temp°C, wiatr $wind m/s, wilgotność $humid%',
    'cs': 'Počasí: $temp°C, vítr $wind m/s, vlhkost $humid%',
    'hu': 'Időjárás: $temp°C, szél $wind m/s, páratartalom $humid%',
    'uk': 'Погода: $temp°C, вітер $wind м/с, вологість $humid%',
    'ja': '天気: $temp°C、風速 $wind m/s、湿度 $humid%',
    'ko': '날씨: $temp°C, 바람 $wind m/s, 습도 $humid%',
  });

  // === Дополнительные ===
  String get notificationPermissionDenied => _t({
    'en': 'Allow notifications in device settings',
    'ru': 'Разрешите уведомления в настройках устройства',
    'de': 'Benachrichtigungen in den Geräteeinstellungen erlauben',
    'fr': 'Autorisez les notifications dans les paramètres',
    'es': 'Permite las notificaciones en los ajustes',
    'pt': 'Permita notificações nas configurações',
    'it': 'Consenti le notifiche nelle impostazioni',
    'sv': 'Tillåt aviseringar i enhetens inställningar',
    'fi': 'Salli ilmoitukset laitteen asetuksissa',
    'nb': 'Tillat varsler i enhetsinnstillingene',
    'da': 'Tillad notifikationer i enhedsindstillinger',
    'nl': 'Sta meldingen toe in apparaatinstellingen',
    'pl': 'Zezwól na powiadomienia w ustawieniach urządzenia',
    'cs': 'Povolte oznámení v nastavení zařízení',
    'hu': 'Engedélyezze az értesítéseket az eszköz beállításaiban',
    'uk': 'Дозвольте сповіщення в налаштуваннях пристрою',
    'ja': 'デバイス設定で通知を許可してください',
    'ko': '기기 설정에서 알림을 허용하세요',
  });
  String get saveError => _t({
    'en': 'Save error',
    'ru': 'Ошибка сохранения',
    'de': 'Speicherfehler',
    'fr': 'Erreur de sauvegarde',
    'es': 'Error al guardar',
    'pt': 'Erro ao salvar',
    'it': 'Errore di salvataggio',
    'sv': 'Sparfel',
    'fi': 'Tallennusvirhe',
    'nb': 'Lagringsfeil',
    'da': 'Gemningsfejl',
    'nl': 'Opslagfout',
    'pl': 'Błąd zapisu',
    'cs': 'Chyba ukládání',
    'hu': 'Mentési hiba',
    'uk': 'Помилка збереження',
    'ja': '保存エラー',
    'ko': '저장 오류',
  });
  String get triggers => _t({
    'en': 'Triggers',
    'ru': 'Триггеры',
    'de': 'Auslöser',
    'fr': 'Déclencheurs',
    'es': 'Desencadenantes',
    'pt': 'Gatilhos',
    'it': 'Fattori scatenanti',
    'sv': 'Utlösare',
    'fi': 'Laukaisijat',
    'nb': 'Utløsere',
    'da': 'Udløsere',
    'nl': 'Triggers',
    'pl': 'Wyzwalacze',
    'cs': 'Spouštěče',
    'hu': 'Kiváltók',
    'uk': 'Тригери',
    'ja': '誘因',
    'ko': '유발 요인',
  });
  String get fingers => _t({
    'en': 'Fingers',
    'ru': 'Пальцы',
    'de': 'Finger',
    'fr': 'Doigts',
    'es': 'Dedos',
    'pt': 'Dedos',
    'it': 'Dita',
    'sv': 'Fingrar',
    'fi': 'Sormet',
    'nb': 'Fingre',
    'da': 'Fingre',
    'nl': 'Vingers',
    'pl': 'Palce',
    'cs': 'Prsty',
    'hu': 'Ujjak',
    'uk': 'Пальці',
    'ja': '指',
    'ko': '손가락',
  });
  String get weather => _t({
    'en': 'Weather',
    'ru': 'Погода',
    'de': 'Wetter',
    'fr': 'Météo',
    'es': 'Clima',
    'pt': 'Clima',
    'it': 'Meteo',
    'sv': 'Väder',
    'fi': 'Sää',
    'nb': 'Vær',
    'da': 'Vejr',
    'nl': 'Weer',
    'pl': 'Pogoda',
    'cs': 'Počasí',
    'hu': 'Időjárás',
    'uk': 'Погода',
    'ja': '天気',
    'ko': '날씨',
  });
  String get notes => _t({
    'en': 'Notes',
    'ru': 'Заметки',
    'de': 'Notizen',
    'fr': 'Notes',
    'es': 'Notas',
    'pt': 'Notas',
    'it': 'Note',
    'sv': 'Anteckningar',
    'fi': 'Muistiinpanot',
    'nb': 'Notater',
    'da': 'Bemærkninger',
    'nl': 'Notities',
    'pl': 'Notatki',
    'cs': 'Poznámky',
    'hu': 'Jegyzetek',
    'uk': 'Нотатки',
    'ja': 'メモ',
    'ko': '메모',
  });
  String get dailyAt1230 => _t({
    'en': 'Daily at 12:30',
    'ru': 'Ежедневно в 12:30',
    'de': 'Täglich um 12:30',
    'fr': 'Chaque jour à 12h30',
    'es': 'Diariamente a las 12:30',
    'pt': 'Diariamente às 12:30',
    'it': 'Ogni giorno alle 12:30',
    'sv': 'Dagligen kl. 12:30',
    'fi': 'Päivittäin klo 12:30',
    'nb': 'Daglig kl. 12:30',
    'da': 'Dagligt kl. 12:30',
    'nl': 'Dagelijks om 12:30',
    'pl': 'Codziennie o 12:30',
    'cs': 'Denně ve 12:30',
    'hu': 'Naponta 12:30-kor',
    'uk': 'Щоденно о 12:30',
    'ja': '毎日12:30',
    'ko': '매일 12:30',
  });
  String get fullPrivacyPolicy => _t({
    'en': 'Full Privacy Policy',
    'ru': 'Полный текст Privacy Policy',
    'de': 'Vollständige Datenschutzrichtlinie',
    'fr': 'Politique de confidentialité complète',
    'es': 'Política de privacidad completa',
    'pt': 'Política de privacidade completa',
    'it': 'Informativa privacy completa',
    'sv': 'Fullständig integritetspolicy',
    'fi': 'Täydellinen tietosuojakäytäntö',
    'nb': 'Fullstendige personvernregler',
    'da': 'Fuldstændig privatlivspolitik',
    'nl': 'Volledig privacybeleid',
    'pl': 'Pełna polityka prywatności',
    'cs': 'Úplné zásady ochrany osobních údajů',
    'hu': 'Teljes adatvédelmi irányelvek',
    'uk': 'Повна політика конфіденційності',
    'ja': '完全なプライバシーポリシー',
    'ko': '전체 개인정보 처리방침',
  });
  String get contactEmail => 'vasolog.app@gmail.com';

  // === Настройки ===
  String get settings => _t({
    'en': 'Settings',
    'ru': 'Настройки',
    'de': 'Einstellungen',
    'fr': 'Paramètres',
    'es': 'Ajustes',
    'pt': 'Configurações',
    'it': 'Impostazioni',
    'sv': 'Inställningar',
    'fi': 'Asetukset',
    'nb': 'Innstillinger',
    'da': 'Indstillinger',
    'nl': 'Instellingen',
    'pl': 'Ustawienia',
    'cs': 'Nastavení',
    'hu': 'Beállítások',
    'uk': 'Налаштування',
    'ja': '設定',
    'ko': '설정',
  });
  String get language => _t({
    'en': 'Language',
    'ru': 'Язык',
    'de': 'Sprache',
    'fr': 'Langue',
    'es': 'Idioma',
    'pt': 'Idioma',
    'it': 'Lingua',
    'sv': 'Språk',
    'fi': 'Kieli',
    'nb': 'Språk',
    'da': 'Sprog',
    'nl': 'Taal',
    'pl': 'Język',
    'cs': 'Jazyk',
    'hu': 'Nyelv',
    'uk': 'Мова',
    'ja': '言語',
    'ko': '언어',
  });
  String get systemDefault => _t({
    'en': 'System default',
    'ru': 'Системный',
    'de': 'Systemstandard',
    'fr': 'Système',
    'es': 'Sistema',
    'pt': 'Sistema',
    'it': 'Sistema',
    'sv': 'System',
    'fi': 'Järjestelmä',
    'nb': 'System',
    'da': 'System',
    'nl': 'Systeem',
    'pl': 'Systemowy',
    'cs': 'Systémový',
    'hu': 'Rendszer',
    'uk': 'Системна',
    'ja': 'システム',
    'ko': '시스템',
  });
  // === About screen: длинные тексты ===
  String get medicalDisclaimerBody => _t({
    'en':
        'VasoLog is NOT a medical device. The app is not intended for '
        'diagnosis, treatment, or prevention of any disease.\n\n'
        'The data in this app is for informational purposes only and does '
        'not replace consultation with a doctor.\n\n'
        'If symptoms appear, consult a rheumatologist.',
    'ru':
        'VasoLog НЕ является медицинским устройством. '
        'Приложение не предназначено для диагностики, лечения '
        'или профилактики каких-либо заболеваний.\n\n'
        'Данные приложения носят исключительно информационный '
        'характер и не заменяют консультацию врача.\n\n'
        'При появлении симптомов обратитесь к ревматологу.',
    'de':
        'VasoLog ist KEIN Medizinprodukt. Die App ist nicht zur '
        'Diagnose, Behandlung oder Vorbeugung von Krankheiten bestimmt.\n\n'
        'Die Daten dienen nur zu Informationszwecken und ersetzen keine '
        'ärztliche Beratung.\n\n'
        'Bei Symptomen konsultieren Sie einen Rheumatologen.',
    'fr':
        "VasoLog n'est PAS un dispositif médical. L'application n'est pas "
        'destinée au diagnostic, au traitement ou à la prévention de '
        "maladies.\n\nLes données sont à titre informatif uniquement et ne "
        "remplacent pas une consultation médicale.\n\n"
        "En cas de symptômes, consultez un rhumatologue.",
    'es':
        'VasoLog NO es un dispositivo médico. La aplicación no está '
        'destinada al diagnóstico, tratamiento ni prevención de '
        'enfermedades.\n\nLos datos son solo informativos y no sustituyen '
        'la consulta con un médico.\n\n'
        'Si aparecen síntomas, consulte a un reumatólogo.',
    'pt':
        'VasoLog NÃO é um dispositivo médico. O aplicativo não se destina '
        'a diagnóstico, tratamento ou prevenção de doenças.\n\n'
        'Os dados são apenas informativos e não substituem a consulta '
        'com um médico.\n\nSe surgirem sintomas, consulte um reumatologista.',
    'it':
        'VasoLog NON è un dispositivo medico. L\'app non è destinata '
        'alla diagnosi, al trattamento o alla prevenzione di malattie.\n\n'
        'I dati sono solo a scopo informativo e non sostituiscono il '
        'consulto medico.\n\nIn caso di sintomi, consulta un reumatologo.',
    'sv':
        'VasoLog är INTE en medicinteknisk produkt. Appen är inte avsedd '
        'för diagnos, behandling eller förebyggande av sjukdom.\n\n'
        'Data i appen är endast i informationssyfte och ersätter inte '
        'läkarkonsultation.\n\n'
        'Kontakta en reumatolog vid symtom.',
    'fi':
        'VasoLog EI ole lääkinnällinen laite. Sovellusta ei ole tarkoitettu '
        'sairauksien diagnosointiin, hoitoon tai ehkäisyyn.\n\n'
        'Sovelluksen tiedot ovat vain tiedoksi eivätkä korvaa lääkärin '
        'konsultaatiota.\n\n'
        'Jos oireita ilmenee, ota yhteyttä reumatologiin.',
    'nb':
        'VasoLog er IKKE et medisinsk utstyr. Appen er ikke ment for '
        'diagnostisering, behandling eller forebygging av sykdommer.\n\n'
        'Dataene er kun til informasjon og erstatter ikke legekonsultasjon.\n\n'
        'Kontakt en revmatolog hvis symptomer oppstår.',
    'da':
        'VasoLog er IKKE medicinsk udstyr. Appen er ikke beregnet til '
        'diagnosticering, behandling eller forebyggelse af sygdomme.\n\n'
        'Dataene er kun vejledende og erstatter ikke lægekonsultation.\n\n'
        'Konsultér en reumatolog, hvis der opstår symptomer.',
    'nl':
        'VasoLog is GEEN medisch hulpmiddel. De app is niet bedoeld voor '
        'diagnose, behandeling of preventie van ziekten.\n\n'
        'De gegevens dienen uitsluitend ter informatie en vervangen geen '
        'medisch consult.\n\n'
        'Raadpleeg een reumatoloog bij symptomen.',
    'pl':
        'VasoLog NIE jest wyrobem medycznym. Aplikacja nie jest przeznaczona '
        'do diagnozowania, leczenia ani zapobiegania chorobom.\n\n'
        'Dane mają wyłącznie charakter informacyjny i nie zastępują '
        'konsultacji lekarskiej.\n\n'
        'W razie objawów skontaktuj się z reumatologiem.',
    'cs':
        'VasoLog NENÍ zdravotnický prostředek. Aplikace není určena k '
        'diagnostice, léčbě ani prevenci jakýchkoli onemocnění.\n\n'
        'Data slouží pouze pro informační účely a nenahrazují konzultaci '
        's lékařem.\n\n'
        'Při výskytu příznaků se obraťte na revmatologa.',
    'hu':
        'A VasoLog NEM orvostechnikai eszköz. Az alkalmazás nem szolgál '
        'betegségek diagnosztizálására, kezelésére vagy megelőzésére.\n\n'
        'Az adatok kizárólag tájékoztató jellegűek, és nem helyettesítik '
        'az orvosi konzultációt.\n\n'
        'Tünetek esetén forduljon reumatológushoz.',
    'uk':
        'VasoLog НЕ є медичним пристроєм. Додаток не призначений для '
        'діагностики, лікування чи профілактики захворювань.\n\n'
        'Дані мають лише інформаційний характер і не замінюють '
        'консультацію лікаря.\n\nЗа появи симптомів зверніться до ревматолога.',
    'ja':
        'VasoLogは医療機器ではありません。このアプリは疾病の診断、治療、'
        '予防を目的としていません。\n\nアプリのデータは情報提供のみを目的と'
        'しており、医師への相談に代わるものではありません。\n\n'
        '症状が現れた場合はリウマチ専門医に相談してください。',
    'ko':
        'VasoLog는 의료 기기가 아닙니다. 이 앱은 질병의 진단, 치료 또는 '
        '예방을 목적으로 하지 않습니다.\n\n앱의 데이터는 정보 제공 목적으로만 '
        '사용되며 의사와의 상담을 대체하지 않습니다.\n\n'
        '증상이 나타나면 류마티스 전문의와 상담하세요.',
  });

  String get privacyPolicyBody => _t({
    'en':
        'What data is collected:\n'
        '- Attack records (stored locally on your device)\n'
        '- Location (only to determine weather, not shared with third parties)\n'
        '- Photos (stored locally on your device)\n\n'
        'Where data is sent:\n'
        '- Open-Meteo API: only coordinates are sent for weather\n'
        '- No personal or medical data is sent to any server\n\n'
        'Data storage:\n'
        '- All data is stored exclusively on your device\n'
        '- You can delete all data by uninstalling the app\n'
        '- PDF reports are generated locally',
    'ru':
        'Какие данные собираются:\n'
        '- Записи о приступах (хранятся локально на устройстве)\n'
        '- Геолокация (только для определения погоды, не передаётся третьим лицам)\n'
        '- Фотографии (хранятся локально на устройстве)\n\n'
        'Куда передаются данные:\n'
        '- Open-Meteo API: передаются только координаты для получения погоды\n'
        '- Никакие персональные или медицинские данные не передаются на серверы\n\n'
        'Хранение данных:\n'
        '- Все данные хранятся исключительно на вашем устройстве\n'
        '- Вы можете удалить все данные удалив приложение\n'
        '- PDF-отчёты создаются локально',
    'de':
        'Welche Daten werden erfasst:\n'
        '- Anfallsprotokolle (lokal auf Ihrem Gerät gespeichert)\n'
        '- Standort (nur zur Wetterbestimmung, nicht an Dritte weitergegeben)\n'
        '- Fotos (lokal auf Ihrem Gerät gespeichert)\n\n'
        'Wohin Daten gesendet werden:\n'
        '- Open-Meteo API: nur Koordinaten für Wetterdaten\n'
        '- Keine persönlichen oder medizinischen Daten werden an Server gesendet\n\n'
        'Datenspeicherung:\n'
        '- Alle Daten bleiben ausschließlich auf Ihrem Gerät\n'
        '- Beim Deinstallieren der App werden alle Daten gelöscht\n'
        '- PDF-Berichte werden lokal erstellt',
    'fr':
        'Données collectées :\n'
        '- Enregistrements de crises (stockés localement sur votre appareil)\n'
        '- Localisation (uniquement pour la météo, non partagée avec des tiers)\n'
        '- Photos (stockées localement sur votre appareil)\n\n'
        'Où les données sont envoyées :\n'
        '- API Open-Meteo : seules les coordonnées sont envoyées pour la météo\n'
        '- Aucune donnée personnelle ou médicale n\'est envoyée sur des serveurs\n\n'
        'Stockage des données :\n'
        '- Toutes les données sont stockées exclusivement sur votre appareil\n'
        '- Vous pouvez supprimer toutes les données en désinstallant l\'application\n'
        '- Les rapports PDF sont générés localement',
    'es':
        'Qué datos se recopilan:\n'
        '- Registros de crisis (guardados localmente en su dispositivo)\n'
        '- Ubicación (solo para determinar el clima, no se comparte con terceros)\n'
        '- Fotos (guardadas localmente en su dispositivo)\n\n'
        'Adónde se envían los datos:\n'
        '- API Open-Meteo: solo se envían coordenadas para el clima\n'
        '- No se envían datos personales ni médicos a ningún servidor\n\n'
        'Almacenamiento:\n'
        '- Todos los datos se guardan exclusivamente en su dispositivo\n'
        '- Puede eliminar todos los datos desinstalando la aplicación\n'
        '- Los informes PDF se generan localmente',
    'pt':
        'Quais dados são recolhidos:\n'
        '- Registos de crises (armazenados localmente no seu dispositivo)\n'
        '- Localização (apenas para obter o clima, não partilhada com terceiros)\n'
        '- Fotos (armazenadas localmente no seu dispositivo)\n\n'
        'Para onde os dados são enviados:\n'
        '- API Open-Meteo: apenas coordenadas para o clima\n'
        '- Nenhum dado pessoal ou médico é enviado para servidores\n\n'
        'Armazenamento:\n'
        '- Todos os dados ficam exclusivamente no seu dispositivo\n'
        '- Pode apagar todos os dados desinstalando a aplicação\n'
        '- Os relatórios PDF são gerados localmente',
    'it':
        'Quali dati vengono raccolti:\n'
        '- Registrazioni delle crisi (memorizzate localmente sul dispositivo)\n'
        '- Posizione (solo per determinare il meteo, non condivisa con terzi)\n'
        '- Foto (memorizzate localmente sul dispositivo)\n\n'
        'Dove vengono inviati i dati:\n'
        '- API Open-Meteo: solo coordinate per il meteo\n'
        '- Nessun dato personale o medico viene inviato a server\n\n'
        'Memorizzazione:\n'
        '- Tutti i dati rimangono esclusivamente sul dispositivo\n'
        '- È possibile eliminare tutti i dati disinstallando l\'app\n'
        '- I rapporti PDF vengono generati localmente',
    'sv':
        'Vilka data samlas in:\n'
        '- Anfallsregistreringar (lagras lokalt på din enhet)\n'
        '- Plats (endast för väder, delas inte med tredje part)\n'
        '- Foton (lagras lokalt på din enhet)\n\n'
        'Vart data skickas:\n'
        '- Open-Meteo API: endast koordinater skickas för väder\n'
        '- Inga personliga eller medicinska data skickas till servrar\n\n'
        'Datalagring:\n'
        '- All data lagras uteslutande på din enhet\n'
        '- Du kan radera all data genom att avinstallera appen\n'
        '- PDF-rapporter genereras lokalt',
    'fi':
        'Mitä tietoja kerätään:\n'
        '- Kohtausmerkinnät (tallennetaan paikallisesti laitteellesi)\n'
        '- Sijainti (vain säätä varten, ei jaeta kolmansille osapuolille)\n'
        '- Valokuvat (tallennetaan paikallisesti laitteellesi)\n\n'
        'Minne tiedot lähetetään:\n'
        '- Open-Meteo API: vain koordinaatit säätä varten\n'
        '- Henkilötietoja tai terveystietoja ei lähetetä palvelimille\n\n'
        'Tietojen säilytys:\n'
        '- Kaikki tiedot säilytetään yksinomaan laitteellasi\n'
        '- Voit poistaa kaikki tiedot poistamalla sovelluksen\n'
        '- PDF-raportit luodaan paikallisesti',
    'nb':
        'Hvilke data samles inn:\n'
        '- Anfallsregistreringer (lagret lokalt på enheten)\n'
        '- Plassering (kun for å finne vær, deles ikke med tredjepart)\n'
        '- Bilder (lagret lokalt på enheten)\n\n'
        'Hvor data sendes:\n'
        '- Open-Meteo API: kun koordinater sendes for vær\n'
        '- Ingen personlige eller medisinske data sendes til servere\n\n'
        'Datalagring:\n'
        '- Alle data lagres utelukkende på enheten din\n'
        '- Du kan slette alle data ved å avinstallere appen\n'
        '- PDF-rapporter genereres lokalt',
    'da':
        'Hvilke data indsamles:\n'
        '- Anfaldsregistreringer (gemmes lokalt på din enhed)\n'
        '- Placering (kun til vejrdata, deles ikke med tredjepart)\n'
        '- Fotos (gemmes lokalt på din enhed)\n\n'
        'Hvor data sendes:\n'
        '- Open-Meteo API: kun koordinater sendes til vejr\n'
        '- Ingen personlige eller medicinske data sendes til servere\n\n'
        'Datalagring:\n'
        '- Alle data gemmes udelukkende på din enhed\n'
        '- Du kan slette alle data ved at afinstallere appen\n'
        '- PDF-rapporter genereres lokalt',
    'nl':
        'Welke gegevens worden verzameld:\n'
        '- Aanvalsregistraties (lokaal op je apparaat opgeslagen)\n'
        '- Locatie (alleen voor het weer, niet gedeeld met derden)\n'
        '- Foto\'s (lokaal op je apparaat opgeslagen)\n\n'
        'Waar gegevens naartoe gaan:\n'
        '- Open-Meteo API: alleen coördinaten voor het weer\n'
        '- Er worden geen persoonlijke of medische gegevens naar servers gestuurd\n\n'
        'Gegevensopslag:\n'
        '- Alle gegevens worden uitsluitend op je apparaat opgeslagen\n'
        '- Je kunt alle gegevens verwijderen door de app te verwijderen\n'
        '- PDF-rapporten worden lokaal gegenereerd',
    'pl':
        'Jakie dane są zbierane:\n'
        '- Zapisy ataków (przechowywane lokalnie na urządzeniu)\n'
        '- Lokalizacja (tylko do pogody, nieudostępniana osobom trzecim)\n'
        '- Zdjęcia (przechowywane lokalnie na urządzeniu)\n\n'
        'Dokąd wysyłane są dane:\n'
        '- API Open-Meteo: tylko współrzędne do pogody\n'
        '- Żadne dane osobowe ani medyczne nie są wysyłane na serwery\n\n'
        'Przechowywanie danych:\n'
        '- Wszystkie dane są przechowywane wyłącznie na urządzeniu\n'
        '- Możesz usunąć wszystkie dane, odinstalowując aplikację\n'
        '- Raporty PDF są generowane lokalnie',
    'cs':
        'Jaká data se shromažďují:\n'
        '- Záznamy záchvatů (ukládány lokálně v zařízení)\n'
        '- Poloha (pouze pro počasí, nesdílena s třetími stranami)\n'
        '- Fotografie (ukládány lokálně v zařízení)\n\n'
        'Kam se data odesílají:\n'
        '- Open-Meteo API: pouze souřadnice pro počasí\n'
        '- Žádná osobní ani zdravotní data nejsou odesílána na servery\n\n'
        'Ukládání dat:\n'
        '- Všechna data jsou uložena výhradně ve vašem zařízení\n'
        '- Všechna data smažete odinstalací aplikace\n'
        '- PDF reporty se generují lokálně',
    'hu':
        'Milyen adatok gyűlnek:\n'
        '- Rohambejegyzések (helyben, az eszközön tárolva)\n'
        '- Helyadat (csak időjáráshoz, harmadik féllel nem osztjuk meg)\n'
        '- Fényképek (helyben, az eszközön tárolva)\n\n'
        'Hová kerülnek az adatok:\n'
        '- Open-Meteo API: csak koordinátákat küldünk időjáráshoz\n'
        '- Személyes vagy egészségügyi adatot semmilyen szerverre nem küldünk\n\n'
        'Adattárolás:\n'
        '- Minden adat kizárólag a te eszközödön marad\n'
        '- Az alkalmazás eltávolításával minden adat törlődik\n'
        '- A PDF-jelentések helyben készülnek',
    'ja':
        '収集されるデータ:\n'
        '- 発作記録（端末にローカル保存）\n'
        '- 位置情報（天気取得のみに使用、第三者とは共有しません）\n'
        '- 写真（端末にローカル保存）\n\n'
        'データの送信先:\n'
        '- Open-Meteo API: 天気取得のために座標のみを送信\n'
        '- 個人情報や医療情報はサーバーに送信されません\n\n'
        'データの保管:\n'
        '- すべてのデータは端末内のみに保管されます\n'
        '- アプリをアンインストールするとすべてのデータが削除されます\n'
        '- PDFレポートは端末内で生成されます',
    'ko':
        '수집되는 데이터:\n'
        '- 발작 기록 (기기에 로컬 저장)\n'
        '- 위치 (날씨 확인 전용, 제3자와 공유하지 않음)\n'
        '- 사진 (기기에 로컬 저장)\n\n'
        '데이터 전송:\n'
        '- Open-Meteo API: 날씨 확인을 위한 좌표만 전송\n'
        '- 개인정보나 의료 정보는 어떤 서버로도 전송되지 않습니다\n\n'
        '데이터 저장:\n'
        '- 모든 데이터는 기기에만 저장됩니다\n'
        '- 앱 삭제 시 모든 데이터가 삭제됩니다\n'
        '- PDF 보고서는 기기에서 생성됩니다',
    'uk':
        'Які дані збираються:\n'
        '- Записи про напади (зберігаються локально на пристрої)\n'
        '- Геолокація (лише для визначення погоди, не передається третім особам)\n'
        '- Фотографії (зберігаються локально на пристрої)\n\n'
        'Куди передаються дані:\n'
        '- Open-Meteo API: передаються лише координати для погоди\n'
        '- Жодні персональні чи медичні дані не передаються на сервери\n\n'
        'Зберігання даних:\n'
        '- Усі дані зберігаються виключно на вашому пристрої\n'
        '- Ви можете видалити всі дані, видаливши додаток\n'
        '- PDF-звіти створюються локально',
  });

  String get yourRightsBody => _t({
    'en':
        '- You can export your data via PDF reports\n'
        '- You can delete all data by uninstalling the app\n'
        '- You can revoke permissions in device settings\n'
        '- The app works fully offline (except weather)',
    'ru':
        '- Вы можете экспортировать свои данные через PDF-отчёты\n'
        '- Вы можете удалить все данные, удалив приложение\n'
        '- Вы можете отозвать разрешения в настройках устройства\n'
        '- Приложение работает полностью офлайн (кроме погоды)',
    'de':
        '- Sie können Ihre Daten als PDF-Bericht exportieren\n'
        '- Sie können alle Daten durch Deinstallation der App löschen\n'
        '- Sie können Berechtigungen in den Geräteeinstellungen widerrufen\n'
        '- Die App funktioniert vollständig offline (außer Wetter)',
    'fr':
        '- Vous pouvez exporter vos données via des rapports PDF\n'
        '- Vous pouvez supprimer toutes les données en désinstallant l\'application\n'
        '- Vous pouvez révoquer les permissions dans les paramètres de l\'appareil\n'
        '- L\'application fonctionne entièrement hors ligne (sauf pour la météo)',
    'es':
        '- Puede exportar sus datos mediante informes PDF\n'
        '- Puede eliminar todos los datos desinstalando la aplicación\n'
        '- Puede revocar los permisos en los ajustes del dispositivo\n'
        '- La aplicación funciona completamente sin conexión (excepto el clima)',
    'pt':
        '- Pode exportar os seus dados em relatórios PDF\n'
        '- Pode apagar todos os dados desinstalando a aplicação\n'
        '- Pode revogar permissões nas definições do dispositivo\n'
        '- A aplicação funciona totalmente offline (exceto para o clima)',
    'it':
        '- Puoi esportare i tuoi dati tramite rapporti PDF\n'
        '- Puoi eliminare tutti i dati disinstallando l\'app\n'
        '- Puoi revocare i permessi nelle impostazioni del dispositivo\n'
        '- L\'app funziona completamente offline (tranne il meteo)',
    'sv':
        '- Du kan exportera dina data via PDF-rapporter\n'
        '- Du kan radera alla data genom att avinstallera appen\n'
        '- Du kan återkalla behörigheter i enhetens inställningar\n'
        '- Appen fungerar helt offline (förutom väder)',
    'fi':
        '- Voit viedä tietosi PDF-raporttina\n'
        '- Voit poistaa kaikki tiedot poistamalla sovelluksen\n'
        '- Voit peruuttaa luvat laitteen asetuksissa\n'
        '- Sovellus toimii täysin offline (paitsi sää)',
    'nb':
        '- Du kan eksportere dataene dine som PDF-rapport\n'
        '- Du kan slette alle data ved å avinstallere appen\n'
        '- Du kan tilbakekalle tillatelser i enhetens innstillinger\n'
        '- Appen fungerer helt offline (unntatt vær)',
    'da':
        '- Du kan eksportere dine data som PDF-rapport\n'
        '- Du kan slette alle data ved at afinstallere appen\n'
        '- Du kan tilbagekalde tilladelser i enhedens indstillinger\n'
        '- Appen fungerer helt offline (undtagen vejr)',
    'nl':
        '- Je kunt je gegevens exporteren via PDF-rapporten\n'
        '- Je kunt alle gegevens verwijderen door de app te verwijderen\n'
        '- Je kunt rechten intrekken in de apparaatinstellingen\n'
        '- De app werkt volledig offline (behalve weer)',
    'pl':
        '- Możesz wyeksportować swoje dane w raporcie PDF\n'
        '- Możesz usunąć wszystkie dane, odinstalowując aplikację\n'
        '- Możesz cofnąć uprawnienia w ustawieniach urządzenia\n'
        '- Aplikacja działa w pełni offline (oprócz pogody)',
    'cs':
        '- Data můžete exportovat jako PDF report\n'
        '- Všechna data odstraníte odinstalováním aplikace\n'
        '- Oprávnění můžete odvolat v nastavení zařízení\n'
        '- Aplikace funguje plně offline (kromě počasí)',
    'hu':
        '- Az adataidat PDF-jelentésként exportálhatod\n'
        '- Az alkalmazás eltávolításával minden adat törlődik\n'
        '- Az engedélyeket az eszköz beállításaiban vonhatod vissza\n'
        '- Az alkalmazás teljesen offline működik (kivéve az időjárást)',
    'ja':
        '- データはPDFレポートとしてエクスポートできます\n'
        '- アプリをアンインストールするとすべてのデータが削除されます\n'
        '- 権限はデバイス設定から取り消せます\n'
        '- 天気以外はすべてオフラインで動作します',
    'ko':
        '- PDF 보고서로 데이터를 내보낼 수 있습니다\n'
        '- 앱을 삭제하면 모든 데이터가 삭제됩니다\n'
        '- 기기 설정에서 권한을 철회할 수 있습니다\n'
        '- 날씨를 제외한 모든 기능은 완전히 오프라인에서 작동합니다',
    'uk':
        '- Ви можете експортувати дані через PDF-звіти\n'
        '- Ви можете видалити всі дані, видаливши додаток\n'
        '- Ви можете відкликати дозволи в налаштуваннях пристрою\n'
        '- Додаток працює повністю офлайн (крім погоди)',
  });

  // === PDF отчёт (локализованные строки) ===
  String get pdfTitle => _t({
    'en': "VasoLog - Raynaud's Phenomenon Report",
    'ru': 'VasoLog - Отчёт по синдрому Рейно',
    'de': 'VasoLog - Raynaud-Syndrom-Bericht',
    'fr': 'VasoLog - Rapport sur le syndrome de Raynaud',
    'es': 'VasoLog - Informe sobre el síndrome de Raynaud',
    'pt': 'VasoLog - Relatório sobre a síndrome de Raynaud',
    'it': 'VasoLog - Rapporto sulla sindrome di Raynaud',
    'sv': 'VasoLog - Rapport om Raynauds fenomen',
    'fi': 'VasoLog - Raportti Raynaud\'n oireyhtymästä',
    'nb': 'VasoLog - Rapport om Raynauds fenomen',
    'da': 'VasoLog - Rapport om Raynauds syndrom',
    'nl': 'VasoLog - Rapport over het fenomeen van Raynaud',
    'pl': 'VasoLog - Raport o zespole Raynauda',
    'cs': 'VasoLog - Zpráva o Raynaudově fenoménu',
    'hu': 'VasoLog - Jelentés a Raynaud-jelenségről',
    'uk': 'VasoLog - Звіт за синдромом Рейно',
    'ja': 'VasoLog - レイノー現象レポート',
    'ko': 'VasoLog - 레이노 현상 보고서',
  });
  String get pdfPeriod => _t({
    'en': 'Period',
    'ru': 'Период',
    'de': 'Zeitraum',
    'fr': 'Période',
    'es': 'Período',
    'pt': 'Período',
    'it': 'Periodo',
    'sv': 'Period',
    'fi': 'Jakso',
    'nb': 'Periode',
    'da': 'Periode',
    'nl': 'Periode',
    'pl': 'Okres',
    'cs': 'Období',
    'hu': 'Időszak',
    'uk': 'Період',
    'ja': '期間',
    'ko': '기간',
  });
  String get pdfGenerated => _t({
    'en': 'Generated',
    'ru': 'Создано',
    'de': 'Erstellt',
    'fr': 'Généré',
    'es': 'Generado',
    'pt': 'Gerado',
    'it': 'Generato',
    'sv': 'Genererad',
    'fi': 'Luotu',
    'nb': 'Generert',
    'da': 'Oprettet',
    'nl': 'Gegenereerd',
    'pl': 'Wygenerowano',
    'cs': 'Vygenerováno',
    'hu': 'Létrehozva',
    'uk': 'Створено',
    'ja': '作成日時',
    'ko': '생성됨',
  });
  String get pdfSummary => _t({
    'en': 'Summary',
    'ru': 'Сводка',
    'de': 'Zusammenfassung',
    'fr': 'Résumé',
    'es': 'Resumen',
    'pt': 'Resumo',
    'it': 'Riepilogo',
    'sv': 'Sammanfattning',
    'fi': 'Yhteenveto',
    'nb': 'Sammendrag',
    'da': 'Resumé',
    'nl': 'Samenvatting',
    'pl': 'Podsumowanie',
    'cs': 'Shrnutí',
    'hu': 'Összefoglaló',
    'uk': 'Зведення',
    'ja': '概要',
    'ko': '요약',
  });
  String get pdfMetric => _t({
    'en': 'Metric',
    'ru': 'Показатель',
    'de': 'Metrik',
    'fr': 'Indicateur',
    'es': 'Métrica',
    'pt': 'Métrica',
    'it': 'Metrica',
    'sv': 'Mätvärde',
    'fi': 'Mittari',
    'nb': 'Måleverdi',
    'da': 'Måling',
    'nl': 'Metriek',
    'pl': 'Miernik',
    'cs': 'Metrika',
    'hu': 'Mutató',
    'uk': 'Показник',
    'ja': '指標',
    'ko': '지표',
  });
  String get pdfValue => _t({
    'en': 'Value',
    'ru': 'Значение',
    'de': 'Wert',
    'fr': 'Valeur',
    'es': 'Valor',
    'pt': 'Valor',
    'it': 'Valore',
    'sv': 'Värde',
    'fi': 'Arvo',
    'nb': 'Verdi',
    'da': 'Værdi',
    'nl': 'Waarde',
    'pl': 'Wartość',
    'cs': 'Hodnota',
    'hu': 'Érték',
    'uk': 'Значення',
    'ja': '値',
    'ko': '값',
  });
  String get pdfTotalAttacks => _t({
    'en': 'Total Attacks',
    'ru': 'Всего приступов',
    'de': 'Gesamtzahl der Anfälle',
    'fr': 'Total des crises',
    'es': 'Total de crisis',
    'pt': 'Total de crises',
    'it': 'Totale crisi',
    'sv': 'Totalt antal anfall',
    'fi': 'Kohtauksia yhteensä',
    'nb': 'Totalt antall anfall',
    'da': 'Anfald i alt',
    'nl': 'Totaal aanvallen',
    'pl': 'Ataki ogółem',
    'cs': 'Záchvaty celkem',
    'hu': 'Összes roham',
    'uk': 'Усього нападів',
    'ja': '発作合計',
    'ko': '총 발작',
  });
  String get pdfAvgSeverity => _t({
    'en': 'Average Severity (RCS)',
    'ru': 'Средняя тяжесть (RCS)',
    'de': 'Durchschnittlicher Schweregrad (RCS)',
    'fr': 'Sévérité moyenne (RCS)',
    'es': 'Gravedad media (RCS)',
    'pt': 'Gravidade média (RCS)',
    'it': 'Gravità media (RCS)',
    'sv': 'Genomsnittlig svårighetsgrad (RCS)',
    'fi': 'Keskimääräinen vakavuus (RCS)',
    'nb': 'Gjennomsnittlig alvorlighet (RCS)',
    'da': 'Gennemsnitlig sværhedsgrad (RCS)',
    'nl': 'Gem. ernst (RCS)',
    'pl': 'Średnie nasilenie (RCS)',
    'cs': 'Průměrná závažnost (RCS)',
    'hu': 'Átlagos súlyosság (RCS)',
    'uk': 'Середня тяжкість (RCS)',
    'ja': '平均重症度 (RCS)',
    'ko': '평균 심각도 (RCS)',
  });
  String get pdfMostCommonTrigger => _t({
    'en': 'Most Common Trigger',
    'ru': 'Самый частый триггер',
    'de': 'Häufigster Auslöser',
    'fr': 'Déclencheur principal',
    'es': 'Desencadenante principal',
    'pt': 'Gatilho principal',
    'it': 'Fattore principale',
    'sv': 'Vanligaste utlösaren',
    'fi': 'Yleisin laukaisija',
    'nb': 'Vanligste utløser',
    'da': 'Hyppigste udløser',
    'nl': 'Meest voorkomende trigger',
    'pl': 'Najczęstszy wyzwalacz',
    'cs': 'Nejčastější spouštěč',
    'hu': 'Leggyakoribb kiváltó ok',
    'uk': 'Найчастіший тригер',
    'ja': '最も多い誘因',
    'ko': '가장 흔한 유발 요인',
  });
  String get pdfAvgTemp => _t({
    'en': 'Avg. Temperature During Attacks',
    'ru': 'Средн. температура при приступах',
    'de': 'Durchschnittstemperatur bei Anfällen',
    'fr': 'Temp. moyenne durant les crises',
    'es': 'Temp. media durante las crisis',
    'pt': 'Temp. média durante as crises',
    'it': 'Temp. media durante le crisi',
    'sv': 'Medeltemp. vid anfall',
    'fi': 'Kesk. lämpötila kohtausten aikana',
    'nb': 'Gj.snitt temp. under anfall',
    'da': 'Gns. temp. under anfald',
    'nl': 'Gem. temp. tijdens aanvallen',
    'pl': 'Śr. temp. podczas ataków',
    'cs': 'Prům. teplota při záchvatech',
    'hu': 'Átl. hőmérséklet rohamok alatt',
    'uk': 'Сер. температура при нападах',
    'ja': '発作時の平均気温',
    'ko': '발작 중 평균 기온',
  });
  String get pdfTriggerAnalysis => _t({
    'en': 'Trigger Analysis',
    'ru': 'Анализ триггеров',
    'de': 'Auslöser-Analyse',
    'fr': 'Analyse des déclencheurs',
    'es': 'Análisis de desencadenantes',
    'pt': 'Análise de gatilhos',
    'it': 'Analisi dei fattori',
    'sv': 'Utlösaranalys',
    'fi': 'Laukaisijoiden analyysi',
    'nb': 'Utløseranalyse',
    'da': 'Udløseranalyse',
    'nl': 'Trigger-analyse',
    'pl': 'Analiza wyzwalaczy',
    'cs': 'Analýza spouštěčů',
    'hu': 'Kiváltó okok elemzése',
    'uk': 'Аналіз тригерів',
    'ja': '誘因分析',
    'ko': '유발 요인 분석',
  });
  String get pdfColTrigger => _t({
    'en': 'Trigger',
    'ru': 'Триггер',
    'de': 'Auslöser',
    'fr': 'Déclencheur',
    'es': 'Desencadenante',
    'pt': 'Gatilho',
    'it': 'Fattore',
    'sv': 'Utlösare',
    'fi': 'Laukaisija',
    'nb': 'Utløser',
    'da': 'Udløser',
    'nl': 'Trigger',
    'pl': 'Wyzwalacz',
    'cs': 'Spouštěč',
    'hu': 'Kiváltó ok',
    'uk': 'Тригер',
    'ja': '誘因',
    'ko': '유발 요인',
  });
  String get pdfColCount => _t({
    'en': 'Count',
    'ru': 'Количество',
    'de': 'Anzahl',
    'fr': 'Nombre',
    'es': 'Cantidad',
    'pt': 'Quantidade',
    'it': 'Conteggio',
    'sv': 'Antal',
    'fi': 'Määrä',
    'nb': 'Antall',
    'da': 'Antal',
    'nl': 'Aantal',
    'pl': 'Liczba',
    'cs': 'Počet',
    'hu': 'Darab',
    'uk': 'Кількість',
    'ja': '回数',
    'ko': '횟수',
  });
  String get pdfColPct => _t({
    'en': '% of Attacks',
    'ru': '% приступов',
    'de': '% der Anfälle',
    'fr': '% des crises',
    'es': '% de crisis',
    'pt': '% de crises',
    'it': '% di crisi',
    'sv': '% av anfall',
    'fi': '% kohtauksista',
    'nb': '% av anfall',
    'da': '% af anfald',
    'nl': '% van aanvallen',
    'pl': '% ataków',
    'cs': '% záchvatů',
    'hu': 'Rohamok %-a',
    'uk': '% нападів',
    'ja': '発作の%',
    'ko': '발작 %',
  });
  String get pdfAttackLog => _t({
    'en': 'Attack Log',
    'ru': 'Журнал приступов',
    'de': 'Anfallsprotokoll',
    'fr': 'Journal des crises',
    'es': 'Registro de crisis',
    'pt': 'Registro de crises',
    'it': 'Registro crisi',
    'sv': 'Anfallslogg',
    'fi': 'Kohtausloki',
    'nb': 'Anfallslogg',
    'da': 'Anfaldslog',
    'nl': 'Aanvallogboek',
    'pl': 'Dziennik ataków',
    'cs': 'Deník záchvatů',
    'hu': 'Rohamnapló',
    'uk': 'Журнал нападів',
    'ja': '発作ログ',
    'ko': '발작 기록',
  });
  String get pdfColDateTime => _t({
    'en': 'Date/Time',
    'ru': 'Дата/Время',
    'de': 'Datum/Zeit',
    'fr': 'Date/Heure',
    'es': 'Fecha/Hora',
    'pt': 'Data/Hora',
    'it': 'Data/Ora',
    'sv': 'Datum/Tid',
    'fi': 'Päivämäärä/Aika',
    'nb': 'Dato/Tid',
    'da': 'Dato/Tid',
    'nl': 'Datum/Tijd',
    'pl': 'Data/Godzina',
    'cs': 'Datum/Čas',
    'hu': 'Dátum/Idő',
    'uk': 'Дата/Час',
    'ja': '日時',
    'ko': '날짜/시간',
  });
  String get pdfColRcs => 'RCS';
  String get pdfColPhase => _t({
    'en': 'Color Phase',
    'ru': 'Фаза цвета',
    'de': 'Farbphase',
    'fr': 'Phase de couleur',
    'es': 'Fase de color',
    'pt': 'Fase de cor',
    'it': 'Fase colore',
    'sv': 'Färgfas',
    'fi': 'Värivaihe',
    'nb': 'Fargefase',
    'da': 'Farvefase',
    'nl': 'Kleurfase',
    'pl': 'Faza koloru',
    'cs': 'Barevná fáze',
    'hu': 'Színfázis',
    'uk': 'Фаза кольору',
    'ja': '色相',
    'ko': '색상 단계',
  });
  String get pdfColTemp => _t({
    'en': 'Temp °C',
    'ru': 'Темп. °C',
    'de': 'Temp. °C',
    'fr': 'Temp. °C',
    'es': 'Temp. °C',
    'pt': 'Temp. °C',
    'it': 'Temp. °C',
    'sv': 'Temp. °C',
    'fi': 'Lämp. °C',
    'nb': 'Temp. °C',
    'da': 'Temp. °C',
    'nl': 'Temp. °C',
    'pl': 'Temp. °C',
    'cs': 'Teplota °C',
    'hu': 'Hőm. °C',
    'uk': 'Темп. °C',
    'ja': '気温 °C',
    'ko': '온도 °C',
  });
  String get pdfColTriggers => _t({
    'en': 'Triggers',
    'ru': 'Триггеры',
    'de': 'Auslöser',
    'fr': 'Déclencheurs',
    'es': 'Desencadenantes',
    'pt': 'Gatilhos',
    'it': 'Fattori',
    'sv': 'Utlösare',
    'fi': 'Laukaisijat',
    'nb': 'Utløsere',
    'da': 'Udløsere',
    'nl': 'Triggers',
    'pl': 'Wyzwalacze',
    'cs': 'Spouštěče',
    'hu': 'Kiváltó okok',
    'uk': 'Тригери',
    'ja': '誘因',
    'ko': '유발 요인',
  });
  String get pdfFooter => _t({
    'en':
        'This report was generated by VasoLog app and is intended for informational purposes. Please consult your healthcare provider for medical advice.',
    'ru':
        'Этот отчёт сгенерирован приложением VasoLog и предназначен только для информационных целей. Пожалуйста, обратитесь к врачу за медицинской консультацией.',
    'de':
        'Dieser Bericht wurde von der VasoLog-App erstellt und dient nur zu Informationszwecken. Bitte konsultieren Sie einen Arzt für eine medizinische Beratung.',
    'fr':
        'Ce rapport a été généré par l\'application VasoLog à titre informatif uniquement. Consultez votre médecin pour tout avis médical.',
    'es':
        'Este informe fue generado por la aplicación VasoLog y es solo con fines informativos. Consulte a su médico para obtener consejo médico.',
    'pt':
        'Este relatório foi gerado pela aplicação VasoLog e destina-se apenas a fins informativos. Consulte o seu médico para obter aconselhamento médico.',
    'it':
        'Questo rapporto è stato generato dall\'app VasoLog a scopo puramente informativo. Consulta il tuo medico per consigli medici.',
    'sv':
        'Denna rapport har genererats av VasoLog-appen och är endast avsedd för informationssyfte. Rådgör med din läkare för medicinsk rådgivning.',
    'fi':
        'Tämän raportin on luonut VasoLog-sovellus, ja se on tarkoitettu vain tiedoksi. Ota yhteyttä lääkäriisi lääketieteellistä neuvoa varten.',
    'nb':
        'Denne rapporten er generert av VasoLog-appen og er kun til informasjonsformål. Kontakt legen din for medisinsk råd.',
    'da':
        'Denne rapport er genereret af VasoLog-appen og er kun til informationsformål. Kontakt din læge for medicinsk rådgivning.',
    'nl':
        'Dit rapport is gegenereerd door de VasoLog-app en is uitsluitend bedoeld ter informatie. Raadpleeg uw arts voor medisch advies.',
    'pl':
        'Raport wygenerowany przez aplikację VasoLog w celach informacyjnych. W sprawach medycznych skonsultuj się z lekarzem.',
    'cs':
        'Tuto zprávu vygenerovala aplikace VasoLog a slouží pouze pro informační účely. Lékařskou radu vyhledejte u svého lékaře.',
    'hu':
        'Ezt a jelentést a VasoLog alkalmazás készítette, és kizárólag tájékoztató jellegű. Orvosi tanácsért fordulj orvosodhoz.',
    'ja':
        'このレポートはVasoLogアプリによって生成され、情報提供のみを目的としています。医学的な助言については医師にご相談ください。',
    'ko':
        '이 보고서는 VasoLog 앱에서 생성되었으며 정보 제공 목적으로만 사용됩니다. 의학적 조언은 담당 의사에게 문의하세요.',
    'uk':
        'Цей звіт створено додатком VasoLog лише в інформаційних цілях. Будь ласка, зверніться до лікаря за медичною консультацією.',
  });

  String get tapHint => _t({
    'en': 'Tap on finger',
    'ru': 'Нажми на палец',
    'de': 'Finger antippen',
    'fr': 'Touchez un doigt',
    'es': 'Toca un dedo',
    'pt': 'Toque no dedo',
    'it': 'Tocca il dito',
    'sv': 'Tryck på finger',
    'fi': 'Napauta sormea',
    'nb': 'Trykk på finger',
    'da': 'Tryk på finger',
    'nl': 'Tik op vinger',
    'pl': 'Dotknij palca',
    'cs': 'Klepněte na prst',
    'hu': 'Érintsd meg az ujjat',
    'uk': 'Натисни на палець',
    'ja': '指をタップ',
    'ko': '손가락 탭',
  });
  String get selectLanguage => _t({
    'en': 'Select language',
    'ru': 'Выбор языка',
    'de': 'Sprache wählen',
    'fr': 'Choisir la langue',
    'es': 'Elegir idioma',
    'pt': 'Escolher idioma',
    'it': 'Seleziona lingua',
    'sv': 'Välj språk',
    'fi': 'Valitse kieli',
    'nb': 'Velg språk',
    'da': 'Vælg sprog',
    'nl': 'Taal kiezen',
    'pl': 'Wybierz język',
    'cs': 'Vybrat jazyk',
    'hu': 'Nyelv kiválasztása',
    'uk': 'Обрати мову',
    'ja': '言語を選択',
    'ko': '언어 선택',
  });

  // === Тяжесть приступа ===
  String get severityLow => _t({
    'en': 'Mild',
    'ru': 'Лёгкий',
    'de': 'Leicht',
    'fr': 'Léger',
    'es': 'Leve',
    'pt': 'Leve',
    'it': 'Lieve',
    'sv': 'Mild',
    'fi': 'Lievä',
    'nb': 'Mild',
    'da': 'Mild',
    'nl': 'Mild',
    'pl': 'Łagodny',
    'cs': 'Mírný',
    'hu': 'Enyhe',
    'uk': 'Легкий',
    'ja': '軽度',
    'ko': '가벼움',
  });
  String get severityModerate => _t({
    'en': 'Moderate',
    'ru': 'Умеренный',
    'de': 'Moderat',
    'fr': 'Modéré',
    'es': 'Moderado',
    'pt': 'Moderado',
    'it': 'Moderato',
    'sv': 'Måttlig',
    'fi': 'Kohtalainen',
    'nb': 'Moderat',
    'da': 'Moderat',
    'nl': 'Matig',
    'pl': 'Umiarkowany',
    'cs': 'Střední',
    'hu': 'Mérsékelt',
    'uk': 'Помірний',
    'ja': '中等度',
    'ko': '중간',
  });
  String get severitySevere => _t({
    'en': 'Severe',
    'ru': 'Сильный',
    'de': 'Schwer',
    'fr': 'Sévère',
    'es': 'Grave',
    'pt': 'Grave',
    'it': 'Grave',
    'sv': 'Svår',
    'fi': 'Vakava',
    'nb': 'Alvorlig',
    'da': 'Alvorlig',
    'nl': 'Ernstig',
    'pl': 'Poważny',
    'cs': 'Vážný',
    'hu': 'Súlyos',
    'uk': 'Важкий',
    'ja': '重度',
    'ko': '심한',
  });
  String get severityCritical => _t({
    'en': 'Critical',
    'ru': 'Тяжёлый',
    'de': 'Kritisch',
    'fr': 'Critique',
    'es': 'Crítico',
    'pt': 'Crítico',
    'it': 'Critico',
    'sv': 'Kritisk',
    'fi': 'Kriittinen',
    'nb': 'Kritisk',
    'da': 'Kritisk',
    'nl': 'Kritiek',
    'pl': 'Krytyczny',
    'cs': 'Kritický',
    'hu': 'Kritikus',
    'uk': 'Критичний',
    'ja': '極度',
    'ko': '극심한',
  });

  // === Метки деталей приступа (история) ===
  String get labelTriggers => _t({
    'en': 'Triggers',
    'ru': 'Триггеры',
    'de': 'Auslöser',
    'fr': 'Déclencheurs',
    'es': 'Desencadenantes',
    'pt': 'Gatilhos',
    'it': 'Fattori scatenanti',
    'sv': 'Utlösare',
    'fi': 'Laukaisijat',
    'nb': 'Utløsere',
    'da': 'Udløsere',
    'nl': 'Triggers',
    'pl': 'Wyzwalacze',
    'cs': 'Spouštěče',
    'hu': 'Kiváltók',
    'uk': 'Тригери',
    'ja': '誘因',
    'ko': '유발 요인',
  });
  String get labelFingers => _t({
    'en': 'Fingers',
    'ru': 'Пальцы',
    'de': 'Finger',
    'fr': 'Doigts',
    'es': 'Dedos',
    'pt': 'Dedos',
    'it': 'Dita',
    'sv': 'Fingrar',
    'fi': 'Sormet',
    'nb': 'Fingre',
    'da': 'Fingre',
    'nl': 'Vingers',
    'pl': 'Palce',
    'cs': 'Prsty',
    'hu': 'Ujjak',
    'uk': 'Пальці',
    'ja': '指',
    'ko': '손가락',
  });
  String get labelDuration => _t({
    'en': 'Duration',
    'ru': 'Длительность',
    'de': 'Dauer',
    'fr': 'Durée',
    'es': 'Duración',
    'pt': 'Duração',
    'it': 'Durata',
    'sv': 'Varaktighet',
    'fi': 'Kesto',
    'nb': 'Varighet',
    'da': 'Varighed',
    'nl': 'Duur',
    'pl': 'Czas trwania',
    'cs': 'Trvání',
    'hu': 'Időtartam',
    'uk': 'Тривалість',
    'ja': '持続時間',
    'ko': '지속 시간',
  });
  String get labelWeather => _t({
    'en': 'Weather',
    'ru': 'Погода',
    'de': 'Wetter',
    'fr': 'Météo',
    'es': 'Clima',
    'pt': 'Clima',
    'it': 'Meteo',
    'sv': 'Väder',
    'fi': 'Sää',
    'nb': 'Vær',
    'da': 'Vejr',
    'nl': 'Weer',
    'pl': 'Pogoda',
    'cs': 'Počasí',
    'hu': 'Időjárás',
    'uk': 'Погода',
    'ja': '天気',
    'ko': '날씨',
  });
  String get labelHumidity => _t({
    'en': 'Hum.',
    'ru': 'Влажн.',
    'de': 'Feuchte',
    'fr': 'Humidité',
    'es': 'Humedad',
    'pt': 'Umidade',
    'it': 'Umidità',
    'sv': 'Fuktigh.',
    'fi': 'Kosteus',
    'nb': 'Fuktigh.',
    'da': 'Luftfugtigh.',
    'nl': 'Vochtigheid',
    'pl': 'Wilgotność',
    'cs': 'Vlhkost',
    'hu': 'Páratartalom',
    'uk': 'Вологість',
    'ja': '湿度',
    'ko': '습도',
  });
  String get minutesAbbr => _t({
    'en': 'min',
    'ru': 'мин',
    'de': 'Min',
    'fr': 'min',
    'es': 'min',
    'pt': 'min',
    'it': 'min',
    'sv': 'min',
    'fi': 'min',
    'nb': 'min',
    'da': 'min',
    'nl': 'min',
    'pl': 'min',
    'cs': 'min',
    'hu': 'perc',
    'uk': 'хв',
    'ja': '分',
    'ko': '분',
  });

  // === Названия пальцев (10 штук) ===
  String get thumbLeft => _t({
    'en': 'Thumb L',   'ru': 'Большой Л',    'de': 'Daumen Li',
    'fr': 'Pouce G',   'es': 'Pulgar Izq',   'pt': 'Polegar E',
    'it': 'Pollice S', 'sv': 'Tumme V',       'fi': 'Peukalo V',
    'nb': 'Tommel V',  'da': 'Tommelf. V',    'nl': 'Duim L',
    'pl': 'Kciuk L',   'cs': 'Palec L',       'hu': 'Hüvelyk B',
    'uk': 'Великий Л', 'ja': '親指 左',        'ko': '엄지 좌',
  });
  String get indexLeft => _t({
    'en': 'Index L',   'ru': 'Указат. Л',    'de': 'Zeig. Li',
    'fr': 'Index G',   'es': 'Índice Izq',   'pt': 'Índice E',
    'it': 'Indice S',  'sv': 'Pekfingr V',    'fi': 'Etusormi V',
    'nb': 'Pekefingr V','da': 'Pegefingr V',  'nl': 'Wijsv. L',
    'pl': 'Wskaz. L',  'cs': 'Ukaz. L',       'hu': 'Mutató B',
    'uk': 'Вказів. Л', 'ja': '人差し指 左',    'ko': '검지 좌',
  });
  String get middleLeft => _t({
    'en': 'Middle L',  'ru': 'Средний Л',    'de': 'Mittelft. Li',
    'fr': 'Majeur G',  'es': 'Medio Izq',    'pt': 'Médio E',
    'it': 'Medio S',   'sv': 'Långfingr V',   'fi': 'Keskisormi V',
    'nb': 'Langfingr V','da': 'Langeft. V',   'nl': 'Midd.v. L',
    'pl': 'Środk. L',  'cs': 'Prostř. L',     'hu': 'Közép B',
    'uk': 'Середній Л','ja': '中指 左',        'ko': '중지 좌',
  });
  String get ringLeft => _t({
    'en': 'Ring L',    'ru': 'Безымян. Л',   'de': 'Ringfingr Li',
    'fr': 'Annulaire G','es': 'Anular Izq',  'pt': 'Anelar E',
    'it': 'Anulare S', 'sv': 'Ringfingr V',   'fi': 'Nimetön V',
    'nb': 'Ringfingr V','da': 'Ringfingr V',  'nl': 'Ringv. L',
    'pl': 'Serdeczny L','cs': 'Prsteník L',   'hu': 'Gyűrűs B',
    'uk': 'Безіменний Л','ja': '薬指 左',      'ko': '약지 좌',
  });
  String get pinkyLeft => _t({
    'en': 'Pinky L',   'ru': 'Мизинец Л',    'de': 'Kleinfingr Li',
    'fr': 'Auriculaire G','es': 'Meñique Izq','pt': 'Mindinho E',
    'it': 'Mignolo S', 'sv': 'Lillfingr V',   'fi': 'Pikkusormi V',
    'nb': 'Lillefingr V','da': 'Lillefingr V', 'nl': 'Pink L',
    'pl': 'Mały L',    'cs': 'Malík L',        'hu': 'Kisujj B',
    'uk': 'Мізинець Л','ja': '小指 左',        'ko': '새끼 좌',
  });
  String get thumbRight => _t({
    'en': 'Thumb R',   'ru': 'Большой П',    'de': 'Daumen Re',
    'fr': 'Pouce D',   'es': 'Pulgar Der',   'pt': 'Polegar D',
    'it': 'Pollice D', 'sv': 'Tumme H',       'fi': 'Peukalo O',
    'nb': 'Tommel H',  'da': 'Tommelf. H',    'nl': 'Duim R',
    'pl': 'Kciuk P',   'cs': 'Palec P',       'hu': 'Hüvelyk J',
    'uk': 'Великий П', 'ja': '親指 右',        'ko': '엄지 우',
  });
  String get indexRight => _t({
    'en': 'Index R',   'ru': 'Указат. П',    'de': 'Zeig. Re',
    'fr': 'Index D',   'es': 'Índice Der',   'pt': 'Índice D',
    'it': 'Indice D',  'sv': 'Pekfingr H',    'fi': 'Etusormi O',
    'nb': 'Pekefingr H','da': 'Pegefingr H',  'nl': 'Wijsv. R',
    'pl': 'Wskaz. P',  'cs': 'Ukaz. P',       'hu': 'Mutató J',
    'uk': 'Вказів. П', 'ja': '人差し指 右',    'ko': '검지 우',
  });
  String get middleRight => _t({
    'en': 'Middle R',  'ru': 'Средний П',    'de': 'Mittelft. Re',
    'fr': 'Majeur D',  'es': 'Medio Der',    'pt': 'Médio D',
    'it': 'Medio D',   'sv': 'Långfingr H',   'fi': 'Keskisormi O',
    'nb': 'Langfingr H','da': 'Langeft. H',   'nl': 'Midd.v. R',
    'pl': 'Środk. P',  'cs': 'Prostř. P',     'hu': 'Közép J',
    'uk': 'Середній П','ja': '中指 右',        'ko': '중지 우',
  });
  String get ringRight => _t({
    'en': 'Ring R',    'ru': 'Безымян. П',   'de': 'Ringfingr Re',
    'fr': 'Annulaire D','es': 'Anular Der',  'pt': 'Anelar D',
    'it': 'Anulare D', 'sv': 'Ringfingr H',   'fi': 'Nimetön O',
    'nb': 'Ringfingr H','da': 'Ringfingr H',  'nl': 'Ringv. R',
    'pl': 'Serdeczny P','cs': 'Prsteník P',   'hu': 'Gyűrűs J',
    'uk': 'Безіменний П','ja': '薬指 右',      'ko': '약지 우',
  });
  String get pinkyRight => _t({
    'en': 'Pinky R',   'ru': 'Мизинец П',    'de': 'Kleinfingr Re',
    'fr': 'Auriculaire D','es': 'Meñique Der','pt': 'Mindinho D',
    'it': 'Mignolo D', 'sv': 'Lillfingr H',   'fi': 'Pikkusormi O',
    'nb': 'Lillefingr H','da': 'Lillefingr H', 'nl': 'Pink R',
    'pl': 'Mały P',    'cs': 'Malík P',        'hu': 'Kisujj J',
    'uk': 'Мізинець П','ja': '小指 右',        'ko': '새끼 우',
  });

  /// Стабильные ID пальцев для хранения в БД (не меняются между локалями).
  /// Формат: <finger>_<hand>, где hand = l|r.
  static const List<String> fingerKeysLeft = [
    'thumb_l', 'index_l', 'middle_l', 'ring_l', 'pinky_l',
  ];
  static const List<String> fingerKeysRight = [
    'thumb_r', 'index_r', 'middle_r', 'ring_r', 'pinky_r',
  ];

  /// Стабильные ID триггеров для хранения в БД.
  static const List<String> triggerKeys = [
    'cold', 'stress', 'cold_water', 'ac', 'vibration',
    'smoking', 'caffeine', 'exercise', 'emotions', 'medication', 'unknown',
  ];

  /// Локализованное имя пальца по стабильному ID.
  /// Для обратной совместимости со старыми записями (до рефакторинга)
  /// распознаёт также ru-строки, которые использовались как ID раньше.
  String fingerFromKey(String key) {
    switch (key) {
      case 'thumb_l':
      case 'Большой Л':
        return thumbLeft;
      case 'index_l':
      case 'Указат. Л':
        return indexLeft;
      case 'middle_l':
      case 'Средний Л':
        return middleLeft;
      case 'ring_l':
      case 'Безымян. Л':
        return ringLeft;
      case 'pinky_l':
      case 'Мизинец Л':
        return pinkyLeft;
      case 'thumb_r':
      case 'Большой П':
        return thumbRight;
      case 'index_r':
      case 'Указат. П':
        return indexRight;
      case 'middle_r':
      case 'Средний П':
        return middleRight;
      case 'ring_r':
      case 'Безымян. П':
        return ringRight;
      case 'pinky_r':
      case 'Мизинец П':
        return pinkyRight;
      default:
        return key;
    }
  }

  /// Локализованное имя триггера по стабильному ID.
  String triggerFromKey(String key) {
    switch (key) {
      case 'cold':
        return triggerCold;
      case 'stress':
        return triggerStress;
      case 'cold_water':
        return triggerColdWater;
      case 'ac':
        return triggerAC;
      case 'vibration':
        return triggerVibration;
      case 'smoking':
        return triggerSmoking;
      case 'caffeine':
        return triggerCaffeine;
      case 'exercise':
        return triggerExercise;
      case 'emotions':
        return triggerEmotions;
      case 'medication':
        return triggerMedication;
      case 'unknown':
        return triggerUnknown;
      default:
        return key;
    }
  }

  /// Локализованное описание погоды по WMO коду.
  /// Коды: https://open-meteo.com/en/docs (weather_code)
  String wmoDescription(int code) {
    final key = switch (code) {
      0 => 'clear',
      1 || 2 || 3 => 'cloudy',
      45 || 48 => 'fog',
      51 || 53 || 55 => 'drizzle',
      61 || 63 || 65 => 'rain',
      71 || 73 || 75 => 'snow',
      77 => 'snow_grains',
      80 || 81 || 82 => 'showers',
      85 || 86 => 'snow_showers',
      95 => 'thunder',
      96 || 99 => 'thunder_hail',
      _ => 'unknown',
    };
    switch (key) {
      case 'clear':
        return _t({
          'en': 'Clear', 'ru': 'Ясно', 'de': 'Klar', 'fr': 'Clair',
          'es': 'Despejado', 'pt': 'Limpo', 'it': 'Sereno', 'sv': 'Klart',
          'fi': 'Selkeää', 'nb': 'Klart', 'da': 'Klart', 'nl': 'Helder',
          'pl': 'Pogodnie', 'cs': 'Jasno', 'hu': 'Tiszta', 'uk': 'Ясно',
          'ja': '晴れ', 'ko': '맑음',
        });
      case 'cloudy':
        return _t({
          'en': 'Cloudy', 'ru': 'Облачно', 'de': 'Bewölkt', 'fr': 'Nuageux',
          'es': 'Nublado', 'pt': 'Nublado', 'it': 'Nuvoloso', 'sv': 'Molnigt',
          'fi': 'Pilvistä', 'nb': 'Skyet', 'da': 'Skyet', 'nl': 'Bewolkt',
          'pl': 'Pochmurno', 'cs': 'Oblačno', 'hu': 'Felhős', 'uk': 'Хмарно',
          'ja': '曇り', 'ko': '흐림',
        });
      case 'fog':
        return _t({
          'en': 'Fog', 'ru': 'Туман', 'de': 'Nebel', 'fr': 'Brouillard',
          'es': 'Niebla', 'pt': 'Nevoeiro', 'it': 'Nebbia', 'sv': 'Dimma',
          'fi': 'Sumua', 'nb': 'Tåke', 'da': 'Tåge', 'nl': 'Mist',
          'pl': 'Mgła', 'cs': 'Mlha', 'hu': 'Köd', 'uk': 'Туман',
          'ja': '霧', 'ko': '안개',
        });
      case 'drizzle':
        return _t({
          'en': 'Drizzle', 'ru': 'Морось', 'de': 'Nieselregen', 'fr': 'Bruine',
          'es': 'Llovizna', 'pt': 'Chuvisco', 'it': 'Pioviggine', 'sv': 'Duggregn',
          'fi': 'Tihkusade', 'nb': 'Yr', 'da': 'Støvregn', 'nl': 'Motregen',
          'pl': 'Mżawka', 'cs': 'Mrholení', 'hu': 'Szitálás', 'uk': 'Мряка',
          'ja': '霧雨', 'ko': '이슬비',
        });
      case 'rain':
        return _t({
          'en': 'Rain', 'ru': 'Дождь', 'de': 'Regen', 'fr': 'Pluie',
          'es': 'Lluvia', 'pt': 'Chuva', 'it': 'Pioggia', 'sv': 'Regn',
          'fi': 'Sade', 'nb': 'Regn', 'da': 'Regn', 'nl': 'Regen',
          'pl': 'Deszcz', 'cs': 'Déšť', 'hu': 'Eső', 'uk': 'Дощ',
          'ja': '雨', 'ko': '비',
        });
      case 'snow':
        return _t({
          'en': 'Snow', 'ru': 'Снег', 'de': 'Schnee', 'fr': 'Neige',
          'es': 'Nieve', 'pt': 'Neve', 'it': 'Neve', 'sv': 'Snö',
          'fi': 'Lumi', 'nb': 'Snø', 'da': 'Sne', 'nl': 'Sneeuw',
          'pl': 'Śnieg', 'cs': 'Sníh', 'hu': 'Hó', 'uk': 'Сніг',
          'ja': '雪', 'ko': '눈',
        });
      case 'snow_grains':
        return _t({
          'en': 'Snow grains', 'ru': 'Снежная крупа', 'de': 'Schneegriesel',
          'fr': 'Grésil', 'es': 'Cinarra', 'pt': 'Grãos de neve',
          'it': 'Granuli di neve', 'sv': 'Snökorn', 'fi': 'Lumijyvät',
          'nb': 'Snøkorn', 'da': 'Snekorn', 'nl': 'Sneeuwkorrels',
          'pl': 'Ziarna śniegu', 'cs': 'Sněhová zrna', 'hu': 'Hódara',
          'uk': 'Снігова крупа', 'ja': '霧雪', 'ko': '싸락눈',
        });
      case 'showers':
        return _t({
          'en': 'Showers', 'ru': 'Ливень', 'de': 'Schauer', 'fr': 'Averses',
          'es': 'Chubascos', 'pt': 'Aguaceiros', 'it': 'Rovesci', 'sv': 'Skurar',
          'fi': 'Kuuroja', 'nb': 'Regnbyger', 'da': 'Byger', 'nl': 'Buien',
          'pl': 'Ulewy', 'cs': 'Přeháňky', 'hu': 'Zápor', 'uk': 'Злива',
          'ja': 'にわか雨', 'ko': '소나기',
        });
      case 'snow_showers':
        return _t({
          'en': 'Snow showers', 'ru': 'Снегопад', 'de': 'Schneeschauer',
          'fr': 'Averses de neige', 'es': 'Chubascos de nieve',
          'pt': 'Aguaceiros de neve', 'it': 'Rovesci di neve',
          'sv': 'Snöbyar', 'fi': 'Lumikuuroja', 'nb': 'Snøbyger',
          'da': 'Snebyger', 'nl': 'Sneeuwbuien', 'pl': 'Śnieżyce',
          'cs': 'Sněhové přeháňky', 'hu': 'Havas zápor',
          'uk': 'Снігопад', 'ja': 'にわか雪', 'ko': '눈 소나기',
        });
      case 'thunder':
        return _t({
          'en': 'Thunderstorm', 'ru': 'Гроза', 'de': 'Gewitter', 'fr': 'Orage',
          'es': 'Tormenta', 'pt': 'Tempestade', 'it': 'Temporale', 'sv': 'Åska',
          'fi': 'Ukkonen', 'nb': 'Tordenvær', 'da': 'Tordenvejr',
          'nl': 'Onweer', 'pl': 'Burza', 'cs': 'Bouřka', 'hu': 'Zivatar',
          'uk': 'Гроза', 'ja': '雷雨', 'ko': '뇌우',
        });
      case 'thunder_hail':
        return _t({
          'en': 'Thunder with hail', 'ru': 'Гроза с градом',
          'de': 'Gewitter mit Hagel', 'fr': 'Orage avec grêle',
          'es': 'Tormenta con granizo', 'pt': 'Tempestade com granizo',
          'it': 'Temporale con grandine', 'sv': 'Åska med hagel',
          'fi': 'Ukkonen ja rakeita', 'nb': 'Torden med hagl',
          'da': 'Torden med hagl', 'nl': 'Onweer met hagel',
          'pl': 'Burza z gradem', 'cs': 'Bouřka s krupobitím',
          'hu': 'Zivatar jégesővel', 'uk': 'Гроза з градом',
          'ja': '雷と雹', 'ko': '우박을 동반한 뇌우',
        });
      default:
        return _t({
          'en': 'Unknown', 'ru': 'Неизвестно', 'de': 'Unbekannt',
          'fr': 'Inconnu', 'es': 'Desconocido', 'pt': 'Desconhecido',
          'it': 'Sconosciuto', 'sv': 'Okänt', 'fi': 'Tuntematon',
          'nb': 'Ukjent', 'da': 'Ukendt', 'nl': 'Onbekend',
          'pl': 'Nieznane', 'cs': 'Neznámé', 'hu': 'Ismeretlen',
          'uk': 'Невідомо', 'ja': '不明', 'ko': '알 수 없음',
        });
    }
  }

  /// Заголовок ежедневного напоминания (push).
  String get reminderDailyTitle => _t({
    'en': 'How are your hands?',
    'ru': 'Как ваши руки?',
    'de': 'Wie geht es Ihren Händen?',
    'fr': 'Comment vont vos mains ?',
    'es': '¿Cómo están tus manos?',
    'pt': 'Como estão as suas mãos?',
    'it': 'Come stanno le tue mani?',
    'sv': 'Hur mår dina händer?',
    'fi': 'Kuinka kätesi voivat?',
    'nb': 'Hvordan har hendene dine det?',
    'da': 'Hvordan har dine hænder det?',
    'nl': 'Hoe gaat het met je handen?',
    'pl': 'Jak Twoje dłonie?',
    'cs': 'Jak se mají vaše ruce?',
    'hu': 'Hogy vannak a kezeid?',
    'uk': 'Як ваші руки?',
    'ja': '手の調子はいかがですか？',
    'ko': '손 상태는 어떠신가요?',
  });
  String get reminderDailyBody => _t({
    'en': 'Log how you feel if you had an attack',
    'ru': 'Запишите состояние, если был приступ',
    'de': 'Erfasse deinen Zustand, wenn du einen Anfall hattest',
    'fr': 'Enregistrez votre état si vous avez eu une crise',
    'es': 'Registra tu estado si tuviste un ataque',
    'pt': 'Registe o seu estado se teve um ataque',
    'it': 'Registra il tuo stato se hai avuto un attacco',
    'sv': 'Logga ditt tillstånd om du hade ett anfall',
    'fi': 'Kirjaa vointisi, jos sinulla oli kohtaus',
    'nb': 'Registrer tilstanden din hvis du hadde et anfall',
    'da': 'Registrer din tilstand, hvis du havde et anfald',
    'nl': 'Noteer hoe je je voelt als je een aanval had',
    'pl': 'Zapisz stan, jeśli wystąpił atak',
    'cs': 'Zaznamenejte si stav, pokud jste měli záchvat',
    'hu': 'Jegyezd fel, ha rohamot kaptál',
    'uk': 'Запишіть стан, якщо був напад',
    'ja': '発作があったら状態を記録してください',
    'ko': '발작이 있었다면 상태를 기록하세요',
  });
  String get reminderInactivityTitle => _t({
    'en': 'No records for a while',
    'ru': 'Давно не было записей',
    'de': 'Schon eine Weile keine Einträge',
    'fr': 'Pas d\'enregistrements depuis longtemps',
    'es': 'Hace tiempo que no hay registros',
    'pt': 'Há muito tempo sem registos',
    'it': 'Non ci sono registrazioni da un po\'',
    'sv': 'Inga anteckningar på ett tag',
    'fi': 'Ei merkintöjä vähään aikaan',
    'nb': 'Ingen oppføringer på en stund',
    'da': 'Ingen registreringer i et stykke tid',
    'nl': 'Al een tijdje geen registraties',
    'pl': 'Dawno nie było wpisów',
    'cs': 'Dlouho žádné záznamy',
    'hu': 'Rég nem volt bejegyzés',
    'uk': 'Давно не було записів',
    'ja': 'しばらく記録がありません',
    'ko': '한동안 기록이 없네요',
  });
  String get reminderInactivityBody => _t({
    'en': 'All good? Log if you had an attack',
    'ru': 'Всё хорошо? Если был приступ - запишите его',
    'de': 'Alles gut? Erfasse es, wenn du einen Anfall hattest',
    'fr': 'Tout va bien ? Enregistrez si vous avez eu une crise',
    'es': '¿Todo bien? Registra si tuviste un ataque',
    'pt': 'Tudo bem? Registe se teve um ataque',
    'it': 'Tutto bene? Registra se hai avuto un attacco',
    'sv': 'Allt bra? Logga om du fick ett anfall',
    'fi': 'Onko kaikki hyvin? Kirjaa, jos sinulla oli kohtaus',
    'nb': 'Alt bra? Registrer om du hadde et anfall',
    'da': 'Alt vel? Registrer, hvis du havde et anfald',
    'nl': 'Alles goed? Log als je een aanval had',
    'pl': 'Wszystko dobrze? Zapisz, jeśli był atak',
    'cs': 'Vše v pořádku? Zapište, pokud jste měli záchvat',
    'hu': 'Minden rendben? Jegyezd fel, ha rohamot kaptál',
    'uk': 'Все гаразд? Якщо був напад - запишіть',
    'ja': '大丈夫ですか？発作があったら記録してください',
    'ko': '괜찮으신가요? 발작이 있었다면 기록하세요',
  });
  String get notificationChannelName => _t({
    'en': 'VasoLog Reminders',
    'ru': 'Напоминания VasoLog',
    'de': 'VasoLog-Erinnerungen',
    'fr': 'Rappels VasoLog',
    'es': 'Recordatorios de VasoLog',
    'pt': 'Lembretes do VasoLog',
    'it': 'Promemoria VasoLog',
    'sv': 'VasoLog-påminnelser',
    'fi': 'VasoLog-muistutukset',
    'nb': 'VasoLog-påminnelser',
    'da': 'VasoLog-påmindelser',
    'nl': 'VasoLog-herinneringen',
    'pl': 'Przypomnienia VasoLog',
    'cs': 'Připomenutí VasoLog',
    'hu': 'VasoLog emlékeztetők',
    'uk': 'Нагадування VasoLog',
    'ja': 'VasoLog リマインダー',
    'ko': 'VasoLog 알림',
  });
  String get notificationChannelDailyDesc => _t({
    'en': 'Daily reminders to log your state',
    'ru': 'Ежедневные напоминания о записи состояния',
    'de': 'Tägliche Erinnerungen, deinen Zustand zu erfassen',
    'fr': 'Rappels quotidiens pour enregistrer votre état',
    'es': 'Recordatorios diarios para registrar tu estado',
    'pt': 'Lembretes diários para registar o seu estado',
    'it': 'Promemoria giornalieri per registrare il tuo stato',
    'sv': 'Dagliga påminnelser att logga ditt tillstånd',
    'fi': 'Päivittäiset muistutukset tilan kirjaamisesta',
    'nb': 'Daglige påminnelser om å registrere tilstanden',
    'da': 'Daglige påmindelser om at registrere din tilstand',
    'nl': 'Dagelijkse herinneringen om je status te loggen',
    'pl': 'Codzienne przypomnienia o zapisaniu stanu',
    'cs': 'Denní připomenutí zapsat stav',
    'hu': 'Napi emlékeztetők állapot rögzítésére',
    'uk': 'Щоденні нагадування про запис стану',
    'ja': '状態を記録する毎日のリマインダー',
    'ko': '상태를 기록하기 위한 일일 알림',
  });
  String get notificationChannelInactivityDesc => _t({
    'en': 'Reminder when there are no records',
    'ru': 'Напоминание при отсутствии записей',
    'de': 'Erinnerung, wenn keine Einträge vorliegen',
    'fr': 'Rappel en l\'absence d\'enregistrements',
    'es': 'Recordatorio cuando no hay registros',
    'pt': 'Lembrete quando não há registos',
    'it': 'Promemoria quando non ci sono registrazioni',
    'sv': 'Påminnelse när det inte finns några anteckningar',
    'fi': 'Muistutus, kun merkintöjä ei ole',
    'nb': 'Påminnelse når det ikke er oppføringer',
    'da': 'Påmindelse, når der ikke er registreringer',
    'nl': 'Herinnering wanneer er geen registraties zijn',
    'pl': 'Przypomnienie, gdy nie ma wpisów',
    'cs': 'Připomenutí, když nejsou žádné záznamy',
    'hu': 'Emlékeztető, ha nincsenek bejegyzések',
    'uk': 'Нагадування при відсутності записів',
    'ja': '記録がない時のリマインダー',
    'ko': '기록이 없을 때 알림',
  });
  String get feedbackEmailSubject => _t({
    'en': 'VasoLog - Feedback',
    'ru': 'VasoLog - Обратная связь',
    'de': 'VasoLog - Feedback',
    'fr': 'VasoLog - Commentaires',
    'es': 'VasoLog - Comentarios',
    'pt': 'VasoLog - Comentários',
    'it': 'VasoLog - Feedback',
    'sv': 'VasoLog - Feedback',
    'fi': 'VasoLog - Palaute',
    'nb': 'VasoLog - Tilbakemelding',
    'da': 'VasoLog - Feedback',
    'nl': 'VasoLog - Feedback',
    'pl': 'VasoLog - Opinia',
    'cs': 'VasoLog - Zpětná vazba',
    'hu': 'VasoLog - Visszajelzés',
    'uk': 'VasoLog - Зворотний зв\'язок',
    'ja': 'VasoLog - フィードバック',
    'ko': 'VasoLog - 피드백',
  });

  /// Нативные названия поддерживаемых языков (на самом языке)
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ru': 'Русский',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'pt': 'Português',
    'it': 'Italiano',
    'sv': 'Svenska',
    'fi': 'Suomi',
    'nb': 'Norsk',
    'da': 'Dansk',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'cs': 'Čeština',
    'hu': 'Magyar',
    'uk': 'Українська',
    'ja': '日本語',
    'ko': '한국어',
  };
}
