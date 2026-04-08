import 'package:flutter/material.dart';

/// Константы приложения
class AppColors {
  // Основная палитра - медицинский синий + тёплые акценты
  static const primary = Color(0xFF5C6BC0); // Индиго
  static const primaryDark = Color(0xFF3949AB); // Тёмный индиго
  static const secondary = Color(0xFFFF7043); // Тёплый оранжевый
  static const accent = Color(0xFF26C6DA); // Циановый акцент
  static const background = Color(0xFFF5F7FA); // Светло-серый фон
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF263238);
  static const textSecondary = Color(0xFF607D8B);

  // Тяжесть
  static const severityLow = Color(0xFF66BB6A); // Зелёный
  static const severityMedium = Color(0xFFFFA726); // Оранжевый
  static const severityHigh = Color(0xFFEF5350); // Красный
  static const severityCritical = Color(0xFFC62828); // Тёмно-красный

  // Фазы Рейно
  static const phaseWhite = Color(0xFFECEFF1);
  static const phaseBlue = Color(0xFF42A5F5);
  static const phaseRed = Color(0xFFEF5350);

  // Градиент для AppBar
  static const gradientStart = Color(0xFF5C6BC0);
  static const gradientEnd = Color(0xFF7E57C2);
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
