import 'package:hive_flutter/hive_flutter.dart';
import '../models/attack_event.dart';

/// Сервис локального хранилища (Hive)
class StorageService {
  static const String _boxName = 'attacks';
  late Box<Map> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// Сохранить приступ
  Future<void> saveAttack(AttackEvent event) async {
    await _box.put(event.id, event.toMap());
  }

  /// Получить все приступы (отсортированные по дате, новые первые)
  List<AttackEvent> getAllAttacks() {
    final attacks = _box.values
        .map((map) => AttackEvent.fromMap(map))
        .toList();
    attacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return attacks;
  }

  /// Получить приступы за период
  List<AttackEvent> getAttacksByDateRange(DateTime start, DateTime end) {
    return getAllAttacks()
        .where((a) => a.timestamp.isAfter(start) && a.timestamp.isBefore(end))
        .toList();
  }

  /// Получить приступы за последние N дней
  List<AttackEvent> getRecentAttacks(int days) {
    final start = DateTime.now().subtract(Duration(days: days));
    return getAllAttacks().where((a) => a.timestamp.isAfter(start)).toList();
  }

  /// Удалить приступ
  Future<void> deleteAttack(String id) async {
    await _box.delete(id);
  }

  /// Количество приступов
  int get attackCount => _box.length;

  /// Средняя тяжесть за последние N дней
  double averageSeverity(int days) {
    final attacks = getRecentAttacks(days);
    if (attacks.isEmpty) return 0;
    return attacks.map((a) => a.severity).reduce((a, b) => a + b) /
        attacks.length;
  }

  /// Самые частые триггеры
  Map<String, int> topTriggers(int days) {
    final attacks = getRecentAttacks(days);
    final triggerCount = <String, int>{};
    for (final attack in attacks) {
      for (final trigger in attack.triggers) {
        triggerCount[trigger] = (triggerCount[trigger] ?? 0) + 1;
      }
    }
    // Сортировка по частоте
    final sorted = triggerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }
}
