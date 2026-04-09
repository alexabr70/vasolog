import 'package:flutter_test/flutter_test.dart';
import 'package:vasolog/models/attack_event.dart';

void main() {
  group('AttackEvent', () {
    late AttackEvent event;

    setUp(() {
      event = AttackEvent(
        id: 'test-123',
        timestamp: DateTime(2026, 4, 9, 14, 30),
        severity: 7,
        colorPhase: 'blue',
        durationMinutes: 15,
        affectedFingers: ['Большой Л', 'Указат. Л'],
        triggers: ['Холод', 'Стресс'],
        notes: 'Тестовая заметка',
        temperature: -5.2,
        humidity: 80,
        pressure: 1013,
        windSpeed: 7.5,
        weatherDescription: 'Снег',
        latitude: 53.9,
        longitude: 27.5,
      );
    });

    test('создаётся с правильными полями', () {
      expect(event.id, 'test-123');
      expect(event.severity, 7);
      expect(event.colorPhase, 'blue');
      expect(event.durationMinutes, 15);
      expect(event.affectedFingers, hasLength(2));
      expect(event.triggers, contains('Холод'));
      expect(event.temperature, -5.2);
    });

    test('severityLabel возвращает правильные метки', () {
      expect(AttackEvent(id: '1', timestamp: DateTime.now(), severity: 0).severityLabel, 'Лёгкий');
      expect(AttackEvent(id: '2', timestamp: DateTime.now(), severity: 2).severityLabel, 'Лёгкий');
      expect(AttackEvent(id: '3', timestamp: DateTime.now(), severity: 3).severityLabel, 'Умеренный');
      expect(AttackEvent(id: '4', timestamp: DateTime.now(), severity: 5).severityLabel, 'Умеренный');
      expect(AttackEvent(id: '5', timestamp: DateTime.now(), severity: 6).severityLabel, 'Сильный');
      expect(AttackEvent(id: '6', timestamp: DateTime.now(), severity: 7).severityLabel, 'Сильный');
      expect(AttackEvent(id: '7', timestamp: DateTime.now(), severity: 8).severityLabel, 'Тяжёлый');
      expect(AttackEvent(id: '8', timestamp: DateTime.now(), severity: 10).severityLabel, 'Тяжёлый');
    });

    test('colorPhaseLabel возвращает русские названия', () {
      expect(AttackEvent(id: '1', timestamp: DateTime.now(), severity: 1).colorPhaseLabel, 'Белый (ишемия)');
      expect(AttackEvent(id: '2', timestamp: DateTime.now(), severity: 1, colorPhase: 'blue').colorPhaseLabel, 'Синий (цианоз)');
      expect(AttackEvent(id: '3', timestamp: DateTime.now(), severity: 1, colorPhase: 'red').colorPhaseLabel, 'Красный (реперфузия)');
      expect(AttackEvent(id: '4', timestamp: DateTime.now(), severity: 1, colorPhase: 'mixed').colorPhaseLabel, 'Смешанный');
      expect(AttackEvent(id: '5', timestamp: DateTime.now(), severity: 1, colorPhase: 'unknown').colorPhaseLabel, 'unknown');
    });

    test('toMap/fromMap roundtrip сохраняет все поля', () {
      final map = event.toMap();
      final restored = AttackEvent.fromMap(map);

      expect(restored.id, event.id);
      expect(restored.timestamp, event.timestamp);
      expect(restored.severity, event.severity);
      expect(restored.colorPhase, event.colorPhase);
      expect(restored.durationMinutes, event.durationMinutes);
      expect(restored.affectedFingers, event.affectedFingers);
      expect(restored.triggers, event.triggers);
      expect(restored.notes, event.notes);
      expect(restored.temperature, event.temperature);
      expect(restored.humidity, event.humidity);
      expect(restored.pressure, event.pressure);
      expect(restored.windSpeed, event.windSpeed);
      expect(restored.weatherDescription, event.weatherDescription);
      expect(restored.latitude, event.latitude);
      expect(restored.longitude, event.longitude);
    });

    test('toMap/fromMap с null полями', () {
      final minimal = AttackEvent(
        id: 'min-1',
        timestamp: DateTime(2026),
        severity: 3,
      );
      final map = minimal.toMap();
      final restored = AttackEvent.fromMap(map);

      expect(restored.notes, isNull);
      expect(restored.photoPath, isNull);
      expect(restored.temperature, isNull);
      expect(restored.latitude, isNull);
      expect(restored.affectedFingers, isEmpty);
      expect(restored.triggers, isEmpty);
      expect(restored.colorPhase, 'white');
      expect(restored.durationMinutes, 0);
    });

    test('fromMap с отсутствующими ключами (обратная совместимость)', () {
      final oldMap = {
        'id': 'old-1',
        'timestamp': '2025-01-01T00:00:00.000',
        'severity': 5,
        // Нет colorPhase, durationMinutes, triggers и т.д.
      };
      final restored = AttackEvent.fromMap(oldMap);
      expect(restored.colorPhase, 'white');
      expect(restored.durationMinutes, 0);
      expect(restored.affectedFingers, isEmpty);
      expect(restored.triggers, isEmpty);
    });
  });
}
