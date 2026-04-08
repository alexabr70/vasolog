import 'package:flutter/foundation.dart';
import '../models/attack_event.dart';
import '../services/storage_service.dart';

/// Провайдер состояния приступов
class AttackProvider extends ChangeNotifier {
  final StorageService _storage;
  List<AttackEvent> _attacks = [];

  AttackProvider(this._storage) {
    _loadAttacks();
  }

  List<AttackEvent> get attacks => _attacks;
  int get totalCount => _attacks.length;

  /// Загрузить из хранилища
  void _loadAttacks() {
    _attacks = _storage.getAllAttacks();
    notifyListeners();
  }

  /// Добавить приступ
  Future<void> addAttack(AttackEvent event) async {
    await _storage.saveAttack(event);
    _loadAttacks();
  }

  /// Удалить приступ
  Future<void> deleteAttack(String id) async {
    await _storage.deleteAttack(id);
    _loadAttacks();
  }

  /// Приступы за последние N дней
  List<AttackEvent> recentAttacks(int days) {
    return _storage.getRecentAttacks(days);
  }

  /// Средняя тяжесть за неделю
  double get weeklyAverageSeverity => _storage.averageSeverity(7);

  /// Средняя тяжесть за месяц
  double get monthlyAverageSeverity => _storage.averageSeverity(30);

  /// Топ триггеры за месяц
  Map<String, int> get monthlyTriggers => _storage.topTriggers(30);

  /// Приступы за период (для отчёта)
  List<AttackEvent> getAttacksByRange(DateTime start, DateTime end) {
    return _storage.getAttacksByDateRange(start, end);
  }

  /// Дней без приступа (streak)
  /// Grace period: 1 день пропуска не ломает streak (хроническое заболевание)
  int get daysSinceLastAttack {
    if (_attacks.isEmpty) return 0;
    final lastAttack = _attacks.first; // отсортированы по дате desc
    return DateTime.now().difference(lastAttack.timestamp).inDays;
  }

  /// Последний приступ (для умных дефолтов)
  AttackEvent? get lastAttack => _attacks.isEmpty ? null : _attacks.first;
}
