import 'package:flutter_test/flutter_test.dart';
import 'package:vasolog/utils/constants.dart';

void main() {
  group('severityColor', () {
    test('возвращает зелёный для лёгких (0-2)', () {
      expect(severityColor(0), AppColors.severityLow);
      expect(severityColor(1), AppColors.severityLow);
      expect(severityColor(2), AppColors.severityLow);
    });

    test('возвращает оранжевый для умеренных (3-5)', () {
      expect(severityColor(3), AppColors.severityMedium);
      expect(severityColor(4), AppColors.severityMedium);
      expect(severityColor(5), AppColors.severityMedium);
    });

    test('возвращает красный для сильных (6-7)', () {
      expect(severityColor(6), AppColors.severityHigh);
      expect(severityColor(7), AppColors.severityHigh);
    });

    test('возвращает тёмно-красный для тяжёлых (8-10)', () {
      expect(severityColor(8), AppColors.severityCritical);
      expect(severityColor(9), AppColors.severityCritical);
      expect(severityColor(10), AppColors.severityCritical);
    });
  });

  group('Constants', () {
    test('availableTriggers содержит все основные триггеры', () {
      expect(availableTriggers, contains('Холод'));
      expect(availableTriggers, contains('Стресс'));
      expect(availableTriggers, contains('Неизвестно'));
      expect(availableTriggers.length, greaterThanOrEqualTo(10));
    });

    test('fingerNames содержит 10 пальцев (5 левых + 5 правых)', () {
      expect(fingerNames, hasLength(10));
      expect(fingerNames.where((f) => f.endsWith('Л')), hasLength(5));
      expect(fingerNames.where((f) => f.endsWith('П')), hasLength(5));
    });

    test('colorPhases содержит 4 фазы', () {
      expect(colorPhases, hasLength(4));
      expect(colorPhases.keys, containsAll(['white', 'blue', 'red', 'mixed']));
    });

    test('AppColors определены корректно', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.secondary, isNotNull);
      expect(AppColors.gradientStart, isNotNull);
      expect(AppColors.gradientEnd, isNotNull);
    });
  });
}
