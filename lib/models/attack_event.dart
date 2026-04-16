import 'package:hive/hive.dart';
import 'package:vasolog/l10n/app_strings.dart';

/// Модель приступа феномена Рейно
class AttackEvent extends HiveObject {
  AttackEvent({
    required this.id,
    required this.timestamp,
    required this.severity,
    this.affectedFingers = const [],
    this.colorPhase = 'white',
    this.durationMinutes = 0,
    this.photoPath,
    this.notes,
    this.triggers = const [],
    this.temperature,
    this.humidity,
    this.pressure,
    this.windSpeed,
    this.weatherDescription,
    this.latitude,
    this.longitude,
  });

  /// Из JSON (Hive хранит как Map)
  factory AttackEvent.fromMap(Map<dynamic, dynamic> map) {
    return AttackEvent(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      severity: map['severity'] as int,
      affectedFingers: List<String>.from(
        (map['affectedFingers'] as List<dynamic>?) ?? <dynamic>[],
      ),
      colorPhase: map['colorPhase'] as String? ?? 'white',
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      photoPath: map['photoPath'] as String?,
      notes: map['notes'] as String?,
      triggers: List<String>.from(
        (map['triggers'] as List<dynamic>?) ?? <dynamic>[],
      ),
      temperature: (map['temperature'] as num?)?.toDouble(),
      humidity: (map['humidity'] as num?)?.toDouble(),
      pressure: (map['pressure'] as num?)?.toDouble(),
      windSpeed: (map['windSpeed'] as num?)?.toDouble(),
      weatherDescription: map['weatherDescription'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
  String id;
  DateTime timestamp;
  int severity; // 0-10 (RCS - Raynaud Condition Score)
  List<String> affectedFingers; // Какие пальцы затронуты
  String colorPhase; // white / blue / red / mixed
  int durationMinutes;
  String? photoPath; // Путь к фото
  String? notes; // Заметки пользователя

  // Триггеры
  List<String> triggers; // cold, stress, vibration, etc.

  // Погодные данные (автоматически)
  double? temperature; // °C
  double? humidity; // %
  double? pressure; // hPa
  double? windSpeed; // м/с
  String? weatherDescription;

  // Геолокация
  double? latitude;
  double? longitude;

  /// В Map для Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'affectedFingers': affectedFingers,
      'colorPhase': colorPhase,
      'durationMinutes': durationMinutes,
      'photoPath': photoPath,
      'notes': notes,
      'triggers': triggers,
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'weatherDescription': weatherDescription,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Описание тяжести по RCS
  String get severityLabel {
    if (severity <= 2) return 'Лёгкий';
    if (severity <= 5) return 'Умеренный';
    if (severity <= 7) return 'Сильный';
    return 'Тяжёлый';
  }

  /// Локализованный цвет фазы
  String get colorPhaseLabel {
    return S.current.phaseFromKey(colorPhase);
  }
}
