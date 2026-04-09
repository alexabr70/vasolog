/// Единые форматтеры для погодных данных.
/// Используется на всех экранах чтобы температура/ветер выглядели одинаково.
library;

/// Форматирует температуру в целое число без "-0°C".
/// 2.3 -> "2", -0.4 -> "0", -5.7 -> "-6", 10.6 -> "11".
String formatTemperature(double temp) {
  final rounded = temp.round();
  // Отдельный случай: -0 и маленькие отрицательные которые округляются к 0
  if (rounded == 0) return '0';
  return '$rounded';
}

/// Форматирует скорость ветра в целое число.
/// 4.2 -> "4", 4.7 -> "5".
String formatWindSpeed(double windMs) => '${windMs.round()}';

/// Форматирует влажность в целое число.
String formatHumidity(double humidityPercent) => '${humidityPercent.round()}';
