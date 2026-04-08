import 'package:flutter_test/flutter_test.dart';
import 'package:vasolog/services/weather_service.dart';

void main() {
  group('WeatherData', () {
    test('создаётся с правильными полями', () {
      final data = WeatherData(
        temperature: -5.0,
        humidity: 85.0,
        pressure: 1015.0,
        windSpeed: 7.0,
        description: 'снег',
      );
      expect(data.temperature, -5.0);
      expect(data.humidity, 85.0);
      expect(data.isCached, false);
    });

    test('isCached по умолчанию false', () {
      final data = WeatherData(
        temperature: 20.0,
        humidity: 50.0,
        pressure: 1013.0,
        windSpeed: 3.0,
        description: 'ясно',
      );
      expect(data.isCached, false);
    });

    test('toJson/fromJson roundtrip', () {
      final original = WeatherData(
        temperature: 15.5,
        humidity: 60.0,
        pressure: 1020.0,
        windSpeed: 2.5,
        description: 'облачно',
        fetchedAt: DateTime(2026, 4, 9, 12, 0),
      );
      final json = original.toJson();
      final restored = WeatherData.fromJson(json);

      expect(restored.temperature, original.temperature);
      expect(restored.humidity, original.humidity);
      expect(restored.pressure, original.pressure);
      expect(restored.windSpeed, original.windSpeed);
      expect(restored.description, original.description);
      expect(restored.isCached, true); // fromJson всегда isCached=true
    });

    test('minutesAgo вычисляется корректно', () {
      final data = WeatherData(
        temperature: 10.0,
        humidity: 50.0,
        pressure: 1013.0,
        windSpeed: 1.0,
        description: 'ясно',
        fetchedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );
      // Допуск ±1 минута из-за времени выполнения теста
      expect(data.minutesAgo, closeTo(15, 1));
    });

    test('fromJson парсит числовые типы (int и double)', () {
      final json = {
        'temperature': 10, // int вместо double
        'humidity': 50,
        'pressure': 1013,
        'windSpeed': 3,
        'description': 'тест',
        'fetchedAt': DateTime.now().toIso8601String(),
      };
      final data = WeatherData.fromJson(json);
      expect(data.temperature, 10.0);
      expect(data.humidity, 50.0);
    });
  });
}
