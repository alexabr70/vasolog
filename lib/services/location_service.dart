import 'package:geolocator/geolocator.dart';

/// Сервис геолокации
class LocationService {
  /// Получить текущие координаты
  Future<Position?> getCurrentPosition() async {
    try {
      // Проверяем что сервис включен
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Проверяем разрешения
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      // Получаем позицию
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Низкая точность = быстрее
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
