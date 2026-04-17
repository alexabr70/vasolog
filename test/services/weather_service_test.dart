import 'package:flutter_test/flutter_test.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/services/weather_service.dart';

void main() {
  group('WeatherData', () {
    setUpAll(() {
      S.init('ru');
    });

    test('создаётся с правильными полями', () {
      final data = WeatherData(
        temperature: -5,
        humidity: 85,
        pressure: 1015,
        windSpeed: 7,
        weatherCode: 71, // snow
      );
      expect(data.temperature, -5.0);
      expect(data.humidity, 85.0);
      expect(data.isCached, false);
    });

    test('isCached по умолчанию false', () {
      final data = WeatherData(
        temperature: 20,
        humidity: 50,
        pressure: 1013,
        windSpeed: 3,
        weatherCode: 0, // clear
      );
      expect(data.isCached, false);
    });

    test('toJson/fromJson roundtrip', () {
      final original = WeatherData(
        temperature: 15.5,
        humidity: 60,
        pressure: 1020,
        windSpeed: 2.5,
        weatherCode: 3, // cloudy
        fetchedAt: DateTime(2026, 4, 9, 12),
      );
      final json = original.toJson();
      final restored = WeatherData.fromJson(json);

      expect(restored.temperature, original.temperature);
      expect(restored.humidity, original.humidity);
      expect(restored.pressure, original.pressure);
      expect(restored.windSpeed, original.windSpeed);
      expect(restored.weatherCode, original.weatherCode);
      expect(restored.isCached, true); // fromJson всегда isCached=true
    });

    test('minutesAgo вычисляется корректно', () {
      final data = WeatherData(
        temperature: 10,
        humidity: 50,
        pressure: 1013,
        windSpeed: 1,
        weatherCode: 0,
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
        'weatherCode': 71,
        'fetchedAt': DateTime.now().toIso8601String(),
      };
      final data = WeatherData.fromJson(json);
      expect(data.temperature, 10.0);
      expect(data.humidity, 50.0);
      expect(data.weatherCode, 71);
    });

    test('description локализуется через S.current', () {
      S.init('en');
      final data = WeatherData(
        temperature: 0,
        humidity: 50,
        pressure: 1013,
        windSpeed: 1,
        weatherCode: 0,
      );
      expect(data.description, 'Clear');
      S.init('ru');
      expect(data.description, 'Ясно');
    });
  });
}
