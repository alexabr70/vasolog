import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vasolog/models/attack_event.dart';

/// Сервис локального хранилища (SharedPreferences + JSON)
/// Надёжно работает на всех Android/Huawei устройствах без зависимости от
/// файловой системы, Hive, KeyStore или path_provider.
class StorageService {
  static const String _prefKey = 'vasolog_attacks_v1';
  late SharedPreferences _prefs;
  final Map<String, Map<String, dynamic>> _data = {};
  List<AttackEvent>? _cachedAttacks;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    try {
      final json = _prefs.getString(_prefKey);
      if (json != null && json.isNotEmpty) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        _data.clear();
        for (final entry in decoded.entries) {
          _data[entry.key] = Map<String, dynamic>.from(entry.value as Map);
        }
      }
    } catch (e) {
      debugPrint('[StorageService] load failed ($e), starting fresh');
      _data.clear();
    }
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setString(_prefKey, jsonEncode(_data));
  }

  /// Сохранить приступ
  Future<void> saveAttack(AttackEvent event) async {
    _data[event.id] = event.toMap();
    _cachedAttacks = null;
    await _saveToPrefs();
  }

  /// Получить все приступы (отсортированные по дате, новые первые)
  List<AttackEvent> getAllAttacks() {
    if (_cachedAttacks != null) return _cachedAttacks!;
    final attacks = _data.values.map(AttackEvent.fromMap).toList();
    attacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _cachedAttacks = attacks;
    return attacks;
  }

  /// Получить приступы за период (включая границы)
  List<AttackEvent> getAttacksByDateRange(DateTime start, DateTime end) {
    return getAllAttacks()
        .where((a) => !a.timestamp.isBefore(start) && !a.timestamp.isAfter(end))
        .toList();
  }

  /// Получить приступы за последние N дней
  List<AttackEvent> getRecentAttacks(int days) {
    final start = DateTime.now().subtract(Duration(days: days));
    return getAllAttacks().where((a) => a.timestamp.isAfter(start)).toList();
  }

  /// Удалить приступ
  Future<void> deleteAttack(String id) async {
    _data.remove(id);
    _cachedAttacks = null;
    await _saveToPrefs();
  }

  /// Количество приступов
  int get attackCount => _data.length;

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
    final sorted = triggerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }
}
