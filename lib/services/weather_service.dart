import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vasolog/l10n/app_strings.dart';

/// Данные о погоде.
/// `weatherCode` - WMO код (https://open-meteo.com/en/docs).
/// Храним код, локализацию делаем через `description` геттер -> S.current.wmoDescription.
class WeatherData {
  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.weatherCode,
    DateTime? fetchedAt,
    this.isCached = false,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    pressure: (json['pressure'] as num).toDouble(),
    windSpeed: (json['windSpeed'] as num).toDouble(),
    weatherCode: (json['weatherCode'] as num?)?.toInt() ?? -1,
    fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    isCached: true,
  );
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final int weatherCode;
  final DateTime fetchedAt;
  final bool isCached;

  /// Локализованное описание погоды по текущей локали.
  String get description => S.current.wmoDescription(weatherCode);

  /// Сколько минут назад загружены данные
  int get minutesAgo => DateTime.now().difference(fetchedAt).inMinutes;

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'pressure': pressure,
    'windSpeed': windSpeed,
    'weatherCode': weatherCode,
    'fetchedAt': fetchedAt.toIso8601String(),
  };
}

/// Сервис погоды через Open-Meteo API (бесплатный, без ключа)
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1';
  static const String _cacheKey = 'cached_weather';
  static const int _cacheMaxMinutes = 30;

  /// Получить текущую погоду по координатам.
  /// Если кэш свежий (< 5 мин) - вернуть его без HTTP запроса.
  /// [forceRefresh] = true пропускает кеш и всегда делает fresh запрос
  /// (для ручного обновления по кнопке юзером).
  Future<WeatherData?> getCurrentWeather(
    double latitude,
    double longitude, {
    bool forceRefresh = false,
  }) async {
    // Свежий кэш - не делаем лишний запрос (одинаковые данные на всех экранах)
    if (!forceRefresh) {
      final cached = await _loadFromCache();
      if (cached != null && cached.minutesAgo < 5) return cached;
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code'
        '&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final weather = WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          humidity: (current['relative_humidity_2m'] as num).toDouble(),
          pressure: (current['surface_pressure'] as num).toDouble(),
          // Open-Meteo даёт km/h, конвертируем в m/s
          windSpeed: (current['wind_speed_10m'] as num).toDouble() / 3.6,
          weatherCode: (current['weather_code'] as num).toInt(),
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
