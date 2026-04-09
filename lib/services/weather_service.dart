import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Данные о погоде
class WeatherData {

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
    DateTime? fetchedAt,
    this.isCached = false,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    pressure: (json['pressure'] as num).toDouble(),
    windSpeed: (json['windSpeed'] as num).toDouble(),
    description: json['description'] as String,
    fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    isCached: true,
  );
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final String description;
  final DateTime fetchedAt;
  final bool isCached;

  /// Сколько минут назад загружены данные
  int get minutesAgo => DateTime.now().difference(fetchedAt).inMinutes;

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'pressure': pressure,
    'windSpeed': windSpeed,
    'description': description,
    'fetchedAt': fetchedAt.toIso8601String(),
  };
}

/// Сервис погоды через Open-Meteo API (бесплатный, без ключа)
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1';
  static const String _cacheKey = 'cached_weather';
  static const int _cacheMaxMinutes = 30;

  /// WMO коды погоды → описание
  static String _wmoDescription(int code) {
    return switch (code) {
      0 => 'Ясно',
      1 || 2 || 3 => 'Облачно',
      45 || 48 => 'Туман',
      51 || 53 || 55 => 'Морось',
      61 || 63 || 65 => 'Дождь',
      71 || 73 || 75 => 'Снег',
      77 => 'Снежная крупа',
      80 || 81 || 82 => 'Ливень',
      85 || 86 => 'Снегопад',
      95 => 'Гроза',
      96 || 99 => 'Гроза с градом',
      _ => 'Неизвестно',
    };
  }

  /// Получить текущую погоду по координатам
  /// Если кэш свежий (< 5 мин) - вернуть его без HTTP запроса
  Future<WeatherData?> getCurrentWeather(
      double latitude, double longitude) async {
    // Свежий кэш - не делаем лишний запрос (одинаковые данные на всех экранах)
    final cached = await _loadFromCache();
    if (cached != null && cached.minutesAgo < 5) return cached;

    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code'
        '&timezone=auto',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final weather = WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          humidity: (current['relative_humidity_2m'] as num).toDouble(),
          pressure: (current['surface_pressure'] as num).toDouble(),
          // Open-Meteo даёт km/h, конвертируем в m/s
          windSpeed: (current['wind_speed_10m'] as num).toDouble() / 3.6,
          description: _wmoDescription(
            (current['weather_code'] as num).toInt(),
          ),
        );
        await _saveToCache(weather);
        return weather;
      }
    } catch (_) {
      // Нет сети / таймаут - пробуем кэш
    }
    return _loadFromCache();
  }

  /// Сохранить погоду в кэш
  Future<void> _saveToCache(WeatherData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(data.toJson()));
  }

  /// Загрузить кэшированную погоду (не старше _cacheMaxMinutes)
  Future<WeatherData?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null) return null;

    try {
      final data = WeatherData.fromJson(
        json.decode(cached) as Map<String, dynamic>,
      );
      if (data.minutesAgo <= _cacheMaxMinutes) return data;
    } catch (_) {}
    return null;
  }
}
