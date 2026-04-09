/// Локализация VasoLog (EN + RU)
/// Определяется автоматически по системной локали устройства
class S {
  static late S current;

  final String locale;
  S._(this.locale);

  static void init(String languageCode) {
    current = S._(languageCode);
  }

  bool get _isRu => locale.startsWith('ru');

  // === Общие ===
  String get appName => 'VasoLog';
  String get save => _isRu ? 'Сохранить' : 'Save';
  String get cancel => _isRu ? 'Отмена' : 'Cancel';
  String get delete => _isRu ? 'Удалить' : 'Delete';
  String get skip => _isRu ? 'Пропустить' : 'Skip';
  String get next => _isRu ? 'Далее' : 'Next';
  String get notNow => _isRu ? 'Не сейчас' : 'Not now';

  // === Навигация ===
  String get tabHome => _isRu ? 'Главная' : 'Home';
  String get tabHistory => _isRu ? 'История' : 'History';
  String get tabReport => _isRu ? 'Отчёт' : 'Report';
  String get tabInfo => _isRu ? 'Инфо' : 'Info';

  // === Главный экран ===
  String get statsTotal => _isRu ? 'Всего' : 'Total';
  String get statsWeek => _isRu ? 'За неделю' : 'This week';
  String get statsAvgRcs => _isRu ? 'Средн. RCS' : 'Avg RCS';
  String get recentAttacks => _isRu ? 'Последние приступы' : 'Recent attacks';
  String get weekTrend => _isRu ? 'Тренд за неделю' : 'Weekly trend';
  String get frequentTriggers => _isRu ? 'Частые триггеры (30 дней)' : 'Common triggers (30 days)';
  String get noRecordsYet => _isRu ? 'Пока нет записей' : 'No records yet';
  String get tapPlusToRecord => _isRu ? 'Нажми + чтобы записать\nпервый приступ' : 'Tap + to record\nyour first attack';
  String get attackDeleted => _isRu ? 'Приступ удалён' : 'Attack deleted';
  String get undo => _isRu ? 'Отменить' : 'Undo';
  String get frostWarning => _isRu ? 'Мороз! Высокий риск приступа. Утепляйте руки.' : 'Freezing! High attack risk. Keep hands warm.';
  String get coldWarning => _isRu ? 'Прохладно. Берегите руки от холода.' : 'Cool weather. Protect your hands.';

  // === Streak ===
  String daysWithout(int days) {
    if (_isRu) {
      final label = _daysLabelRu(days);
      return '$days $label без приступа';
    }
    return '$days ${days == 1 ? "day" : "days"} attack-free';
  }
  String get streakKeepGoing => _isRu ? 'Держись, ты справишься!' : 'Stay strong!';
  String get streakGoodStart => _isRu ? 'Хорошее начало!' : 'Good start!';
  String get streakGreatStreak => _isRu ? 'Отличная серия!' : 'Great streak!';
  String get streakAmazing => _isRu ? 'Потрясающий результат!' : 'Amazing result!';

  String _daysLabelRu(int d) {
    if (d % 10 == 1 && d % 100 != 11) return 'день';
    if (d % 10 >= 2 && d % 10 <= 4 && (d % 100 < 10 || d % 100 >= 20)) return 'дня';
    return 'дней';
  }

  // === Запись приступа ===
  String get recordAttack => _isRu ? 'Записать приступ' : 'Record attack';
  String get editAttack => _isRu ? 'Редактировать' : 'Edit';
  String get likeLastTime => _isRu ? 'Как прошлый раз' : 'Same as last time';
  String get sectionAssessment => _isRu ? 'Оценка приступа' : 'Attack assessment';
  String get severityRcs => _isRu ? 'Тяжесть (RCS)' : 'Severity (RCS)';
  String get fingerColor => _isRu ? 'Цвет пальцев' : 'Finger color';
  String get duration => _isRu ? 'Длительность' : 'Duration';
  String get sectionTriggers => _isRu ? 'Что вызвало?' : 'What triggered it?';
  String get sectionFingers => _isRu ? 'Поражённые пальцы' : 'Affected fingers';
  String get sectionExtra => _isRu ? 'Дополнительно' : 'Additional';
  String get takePhoto => _isRu ? 'Сделать фото' : 'Take photo';
  String get retakePhoto => _isRu ? 'Переснять' : 'Retake';
  String get notesOptional => _isRu ? 'Заметки (необязательно)' : 'Notes (optional)';
  String get notesHint => _isRu ? 'Дополнительные детали...' : 'Additional details...';
  String get attackSaved => _isRu ? 'Приступ записан' : 'Attack recorded';
  String get attackUpdated => _isRu ? 'Приступ обновлён' : 'Attack updated';
  String get leftHand => _isRu ? 'Левая' : 'Left';
  String get rightHand => _isRu ? 'Правая' : 'Right';

  // === Цветовые фазы ===
  String get phaseWhite => _isRu ? 'Белый' : 'White';
  String get phaseBlue => _isRu ? 'Синий' : 'Blue';
  String get phaseRed => _isRu ? 'Красный' : 'Red';
  String get phaseMixed => _isRu ? 'Смешан.' : 'Mixed';

  // === Триггеры ===
  String get triggerCold => _isRu ? 'Холод' : 'Cold';
  String get triggerStress => _isRu ? 'Стресс' : 'Stress';
  String get triggerColdWater => _isRu ? 'Холодная вода' : 'Cold water';
  String get triggerAC => _isRu ? 'Кондиционер' : 'A/C';
  String get triggerVibration => _isRu ? 'Вибрация' : 'Vibration';
  String get triggerSmoking => _isRu ? 'Курение' : 'Smoking';
  String get triggerCaffeine => _isRu ? 'Кофеин' : 'Caffeine';
  String get triggerExercise => _isRu ? 'Физ. нагрузка' : 'Exercise';
  String get triggerEmotions => _isRu ? 'Эмоции' : 'Emotions';
  String get triggerMedication => _isRu ? 'Лекарства' : 'Medication';
  String get triggerUnknown => _isRu ? 'Неизвестно' : 'Unknown';

  // === Онбординг ===
  String get onb1Title => _isRu ? 'Отслеживай приступы Рейно' : "Track Raynaud's attacks";
  String get onb1Desc => _isRu
      ? 'Записывай каждый приступ: тяжесть, цвет, поражённые пальцы, триггеры и длительность.'
      : 'Log every attack: severity, color, affected fingers, triggers and duration.';
  String get onb2Title => _isRu ? 'Автоматическая погода' : 'Automatic weather';
  String get onb2Desc => _isRu
      ? 'Приложение фиксирует температуру, влажность и ветер в момент приступа. Умные подсказки триггеров по погоде.'
      : 'The app records temperature, humidity and wind at the time of attack. Smart weather-based trigger suggestions.';
  String get onb3Title => _isRu ? 'Отчёт для врача' : 'Doctor report';
  String get onb3Desc => _isRu
      ? 'Создавай PDF-отчёты с графиками и статистикой. Покажи ревматологу полную картину.'
      : 'Generate PDF reports with charts and statistics. Show your rheumatologist the full picture.';
  String get onb4Title => _isRu ? 'Геолокация для погоды' : 'Location for weather';
  String get onb4Desc => _isRu
      ? 'Разрешите доступ к геолокации - приложение автоматически зафиксирует температуру, влажность и ветер в момент приступа. Данные не передаются третьим лицам.'
      : 'Allow location access - the app will automatically record temperature, humidity and wind during an attack. Data is not shared with third parties.';
  String get onb5Title => _isRu ? 'Напоминания' : 'Reminders';
  String get onb5Desc => _isRu
      ? 'Ежедневное напоминание в 12:30 поможет не забыть записать приступ. Можно отключить в любой момент.'
      : 'A daily 12:30 reminder helps you never miss logging an attack. Can be turned off anytime.';
  String get enableReminders => _isRu ? 'Включить напоминания' : 'Enable reminders';
  String get allowLocation => _isRu ? 'Разрешить геолокацию' : 'Allow location';

  // === История ===
  String get attacksThisWeek => _isRu ? 'Приступы за неделю' : 'Attacks this week';
  String get statistics => _isRu ? 'Статистика' : 'Statistics';
  String get avgWeekSeverity => _isRu ? 'Средн. тяжесть за неделю' : 'Avg weekly severity';
  String get avgMonthSeverity => _isRu ? 'Средн. тяжесть за месяц' : 'Avg monthly severity';
  String get totalAttacks => _isRu ? 'Всего приступов' : 'Total attacks';
  String get allAttacks => _isRu ? 'Все приступы' : 'All attacks';
  String get noAttacksYet => _isRu ? 'Приступов пока нет.' : 'No attacks yet.';

  // === О приложении ===
  String get aboutTitle => _isRu ? 'О приложении' : 'About';
  String get version => _isRu ? 'Версия' : 'Version';
  String get medicalDisclaimer => _isRu ? 'Медицинский дисклеймер' : 'Medical disclaimer';
  String get privacyPolicy => _isRu ? 'Политика конфиденциальности' : 'Privacy policy';
  String get yourRights => _isRu ? 'Ваши права' : 'Your rights';
  String get reminders => _isRu ? 'Напоминания' : 'Reminders';
  String get feedback => _isRu ? 'Обратная связь' : 'Feedback';
  String get deleteAttackQuestion => _isRu ? 'Удалить приступ?' : 'Delete attack?';
  String get enableGeoLocation => _isRu ? 'Включите геолокацию для автозаполнения погоды' : 'Enable location for automatic weather';
}
