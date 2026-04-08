import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Данные о погоде
class WeatherData {
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final String description;
  final DateTime fetchedAt;
  final bool isCached;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
    DateTime? fetchedAt,
    this.isCached = false,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

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

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    pressure: (json['pressure'] as num).toDouble(),
    windSpeed: (json['windSpeed'] as num).toDouble(),
    description: json['description'] as String,
    fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    isCached: true,
  );
}

/// Сервис погоды через OpenWeatherMap API с кэшированием
class WeatherService {
  static const String _apiKey = String.fromEnvironment('WEATHER_API_KEY');
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _cacheKey = 'cached_weather';
  static const int _cacheMaxMinutes = 30;

  /// Получить текущую погоду по координатам
  /// Если API недоступен - вернёт кэш с пометкой isCached=true
  Future<WeatherData?> getCurrentWeather(
      double latitude, double longitude) async {
    // Без ключа API запрос бессмысленен - сразу идём в кэш
    if (_apiKey.isEmpty) return _loadFromCache();

    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude'
        '&appid=$_apiKey&units=metric&lang=ru',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final weather = WeatherData(
            temperature: (data['main']['temp'] as num).toDouble(),
            humidity: (data['main']['humidity'] as num).toDouble(),
            pressure: (data['main']['pressure'] as num).toDouble(),
            windSpeed: (data['wind']['speed'] as num).toDouble(),
            description: data['weather'][0]['description'] as String,
          );
          await _saveToCache(weather);
          return weather;
        } catch (_) {
          // Неожиданный формат JSON - идём в кэш
        }
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
