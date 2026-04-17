import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vasolog/models/attack_event.dart';

/// Сервис локального хранилища (Hive с шифрованием)
/// Медицинские данные хранятся в зашифрованном box (AES-256)
class StorageService {
  static const String _boxName = 'attacks_encrypted';
  static const String _legacyBoxName = 'attacks';
  static const String _keyAlias = 'vasolog_hive_key';
  late Box<Map<dynamic, dynamic>> _box;

  // Кэш отсортированных приступов (сбрасывается при изменении)
  List<AttackEvent>? _cachedAttacks;

  Future<void> init() async {
    await Hive.initFlutter();

    // Получаем ключ шифрования. Если KeyStore недоступен (Huawei EMUI bug)
    // падаем на незашифрованное хранилище - данные всё равно только локальные.
    try {
      final encryptionKey = await _getOrCreateKey().timeout(
        const Duration(seconds: 8),
      );
      final cipher = HiveAesCipher(encryptionKey);
      _box = await Hive.openBox<Map<dynamic, dynamic>>(
        _boxName,
        encryptionCipher: cipher,
      ).timeout(const Duration(seconds: 5));
      await _migrateFromLegacy(cipher);
    } on Exception catch (e) {
      debugPrint('[StorageService] encrypted init failed ($e), fallback');
      // Fallback - открываем/создаём незашифрованный box
      _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    }
  }

  /// Получить ключ шифрования из secure storage или создать новый.
  /// Защищено timeout + fallback на regenerate для случаев, когда
  /// KeyStore возвращает corrupted state (перенос устройств, Huawei issues).
  Future<List<int>> _getOrCreateKey() async {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    try {
      final existingKey = await secureStorage
          .read(key: _keyAlias)
          .timeout(const Duration(seconds: 5));
      if (existingKey != null) {
        return base64Url.decode(existingKey);
      }
    } catch (e) {
      debugPrint('[StorageService] KeyStore read failed ($e), regenerating');
      // Удалим повреждённый ключ перед regenerate
      try {
        await secureStorage
            .delete(key: _keyAlias)
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    // Генерируем новый 256-bit ключ
    final key = Hive.generateSecureKey();
    try {
      await secureStorage
          .write(key: _keyAlias, value: base64Url.encode(key))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[StorageService] KeyStore write failed ($e), using in-memory key');
    }
    return key;
  }

  /// Миграция из старого незашифрованного box
  Future<void> _migrateFromLegacy(HiveAesCipher cipher) async {
    if (!await Hive.boxExists(_legacyBoxName)) return;

    final legacyBox = await Hive.openBox<Map<dynamic, dynamic>>(_legacyBoxName);
    if (legacyBox.isEmpty) {
      await legacyBox.close();
      return;
    }

    // Копируем все записи в зашифрованный box
    debugPrint(
      '[StorageService] Мигрирую ${legacyBox.length} записей в зашифрованное хранилище',
    );
    for (final key in legacyBox.keys) {
      final value = legacyBox.get(key);
      if (value != null && !_box.containsKey(key)) {
        await _box.put(key, value);
      }
    }

    // Удаляем старый box
    await legacyBox.deleteFromDisk();
    debugPrint('[StorageService] Миграция завершена, старый box удалён');
  }

  /// Сохранить приступ
  Future<void> saveAttack(AttackEvent event) async {
    await _box.put(event.id, event.toMap());
    _cachedAttacks = null; // сброс кэша
  }

  /// Получить все приступы (отсортированные по дате, новые первые)
  List<AttackEvent> getAllAttacks() {
    if (_cachedAttacks != null) return _cachedAttacks!;
    final attacks = _box.values.map(AttackEvent.fromMap).toList();
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
    await _box.delete(id);
    _cachedAttacks = null; // сброс кэша
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
    final sorted = triggerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }
}
