import 'package:flutter/foundation.dart';
import 'package:vasolog/models/attack_event.dart';
import 'package:vasolog/services/notification_service.dart';
import 'package:vasolog/services/storage_service.dart';
import 'package:vasolog/services/widget_service.dart';

/// Провайдер состояния приступов.
/// Поддерживает lazy-init хранилища: создаётся моментально с неинициализированным
/// StorageService, затем [init] вызывается асинхронно после первого кадра.
/// Все геттеры безопасно возвращают defaults пока !_isReady.
class AttackProvider extends ChangeNotifier {
  AttackProvider(this._storage);
  final StorageService _storage;
  List<AttackEvent> _attacks = [];
  bool _isReady = false;

  /// true после успешного StorageService.init()
  bool get isReady => _isReady;

  List<AttackEvent> get attacks => _attacks;
  int get totalCount => _attacks.length;

  /// Инициализировать Hive-хранилище и загрузить данные.
  /// Вызывается асинхронно ПОСЛЕ первого кадра - не блокирует splash.
  Future<void> init() async {
    try {
      await _storage.init();
      _isReady = true;
      _loadAttacks();
    } catch (e) {
      debugPrint('[AttackProvider] init failed: $e');
      _isReady = true; // разблокируем UI даже при ошибке хранилища
      notifyListeners();
    }
  }

  /// Загрузить из хранилища (требует _isReady)
  void _loadAttacks() {
    if (!_isReady) return;
    _attacks = _storage.getAllAttacks();
    notifyListeners();
    _updateWidget();
  }

  /// Добавить приступ
  Future<void> addAttack(AttackEvent event) async {
    if (!_isReady) return;
    await _storage.saveAttack(event);
    _loadAttacks();
    NotificationService().resetInactivityTimer();
  }

  /// Удалить приступ
  Future<void> deleteAttack(String id) async {
    if (!_isReady) return;
    await _storage.deleteAttack(id);
    _loadAttacks();
  }

  /// Приступы за последние N дней
  List<AttackEvent> recentAttacks(int days) {
    if (!_isReady) return [];
    return _storage.getRecentAttacks(days);
  }

  /// Средняя тяжесть за неделю
  double get weeklyAverageSeverity =>
      _isReady ? _storage.averageSeverity(7) : 0;

  /// Средняя тяжесть за месяц
  double get monthlyAverageSeverity =>
      _isReady ? _storage.averageSeverity(30) : 0;

  /// Топ триггеры за месяц
  Map<String, int> get monthlyTriggers =>
      _isReady ? _storage.topTriggers(30) : {};

  /// Приступы за период (для отчёта)
  List<AttackEvent> getAttacksByRange(DateTime start, DateTime end) {
    if (!_isReady) return [];
    return _storage.getAttacksByDateRange(start, end);
  }

  /// Дней без приступа (streak)
  /// -1 = нет данных / не загружено, 0 = приступ сегодня, 1+ = дней без приступа
  int get daysSinceLastAttack {
    if (!_isReady || _attacks.isEmpty) return -1;
    final lastAttack = _attacks.first; // отсортированы по дате desc
    return DateTime.now().difference(lastAttack.timestamp).inDays;
  }

  /// Последний приступ (для умных дефолтов)
  AttackEvent? get lastAttack => _attacks.isEmpty ? null : _attacks.first;

  /// Обновить данные home screen widget
  void _updateWidget() {
    WidgetService.update(
      daysSinceLastAttack: daysSinceLastAttack,
      weeklyCount: recentAttacks(7).length,
      avgSeverity: weeklyAverageSeverity,
    );
  }
}
