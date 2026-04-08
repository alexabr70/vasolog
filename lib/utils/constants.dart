import 'package:flutter/material.dart';

/// Константы приложения
class AppColors {
  static const primary = Color(0xFFE57373); // Тёплый красный
  static const secondary = Color(0xFFFF8A65); // Оранжевый
  static const background = Color(0xFFFFF3E0); // Тёплый фон
  static const surface = Colors.white;
  static const severityLow = Color(0xFF81C784); // Зелёный
  static const severityMedium = Color(0xFFFFB74D); // Оранжевый
  static const severityHigh = Color(0xFFE57373); // Красный
  static const severityCritical = Color(0xFFD32F2F); // Тёмно-красный

  static const phaseWhite = Color(0xFFECEFF1);
  static const phaseBlue = Color(0xFF64B5F6);
  static const phaseRed = Color(0xFFEF5350);
}

/// Доступные триггеры
const availableTriggers = [
  'Холод',
  'Стресс',
  'Холодная вода',
  'Кондиционер',
  'Вибрация',
  'Курение',
  'Кофеин',
  'Физ. нагрузка',
  'Эмоции',
  'Лекарства',
  'Неизвестно',
];

/// Пальцы
const fingerNames = [
  'Большой Л',
  'Указат. Л',
  'Средний Л',
  'Безымян. Л',
  'Мизинец Л',
  'Большой П',
  'Указат. П',
  'Средний П',
  'Безымян. П',
  'Мизинец П',
];

/// Цветовые фазы
const colorPhases = {
  'white': 'Белый (ишемия)',
  'blue': 'Синий (цианоз)',
  'red': 'Красный (реперфузия)',
  'mixed': 'Смешанный',
};

/// Цвет по тяжести
Color severityColor(int severity) {
  if (severity <= 2) return AppColors.severityLow;
  if (severity <= 5) return AppColors.severityMedium;
  if (severity <= 7) return AppColors.severityHigh;
  return AppColors.severityCritical;
}
