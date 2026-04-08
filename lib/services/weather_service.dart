import 'dart:convert';
import 'package:http/http.dart' as http;

/// Данные о погоде
class WeatherData {
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final String description;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
  });
}

/// Сервис погоды через OpenWeatherMap API
class WeatherService {
  // TODO: Вынести в .env / настройки приложения
  // Бесплатный ключ OpenWeatherMap (1000 запросов/день)
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Получить текущую погоду по координатам
  Future<WeatherData?> getCurrentWeather(
      double latitude, double longitude) async {
    // Если ключ не настроен - вернуть заглушку
    if (_apiKey == 'YOUR_API_KEY') {
      return _getMockWeather();
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude'
        '&appid=$_apiKey&units=metric&lang=ru',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData(
          temperature: (data['main']['temp'] as num).toDouble(),
          humidity: (data['main']['humidity'] as num).toDouble(),
          pressure: (data['main']['pressure'] as num).toDouble(),
          windSpeed: (data['wind']['speed'] as num).toDouble(),
          description: data['weather'][0]['description'] as String,
        );
      }
    } catch (e) {
      // Если нет интернета - возвращаем null
      return null;
    }
    return null;
  }

  /// Заглушка для демо (пока нет API ключа)
  WeatherData _getMockWeather() {
    return WeatherData(
      temperature: 5.0,
      humidity: 75.0,
      pressure: 1013.0,
      windSpeed: 3.5,
      description: 'демо-режим (настрой API ключ)',
    );
  }
}
