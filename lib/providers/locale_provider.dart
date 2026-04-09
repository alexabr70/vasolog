import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vasolog/l10n/app_strings.dart';

/// Провайдер выбранного пользователем языка интерфейса.
///
/// Хранит код языка в SharedPreferences (ключ `language_code`):
/// - `null` (ключ отсутствует) - следовать системной локали
/// - `'ru'`, `'en'`, и т.д. - явный выбор пользователя
///
/// При изменении обновляет глобальный [S.current] и уведомляет
/// слушателей, чтобы MaterialApp пересобрался с новым языком.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._languageCode);

  static const _prefsKey = 'language_code';

  String? _languageCode;

  /// Явно выбранный пользователем код языка, либо `null` если используется системный
  String? get languageCode => _languageCode;

  /// Эффективный код языка (с учётом fallback на системную локаль)
  String get effectiveCode =>
      _languageCode ?? ui.PlatformDispatcher.instance.locale.languageCode;

  /// Читает сохранённый выбор из SharedPreferences и инициализирует [S].
  /// Вызывается один раз при старте приложения.
  static Future<LocaleProvider> load(SharedPreferences prefs) async {
    final saved = prefs.getString(_prefsKey);
    final effective =
        saved ?? ui.PlatformDispatcher.instance.locale.languageCode;
    S.init(effective);
    return LocaleProvider(saved);
  }

  /// Установить новый язык. `null` - вернуться к системному.
  Future<void> setLanguage(String? code) async {
    if (_languageCode == code) return;
    _languageCode = code;

    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, code);
    }

    // Перезагружаем S с новым эффективным языком и уведомляем UI
    S.init(effectiveCode);
    notifyListeners();
  }
}
