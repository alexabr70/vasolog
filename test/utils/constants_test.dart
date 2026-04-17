import 'package:flutter_test/flutter_test.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/utils/constants.dart';

void main() {
  setUpAll(() {
    S.init('ru');
  });

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
    test('S.triggerKeys содержит все основные триггеры', () {
      expect(S.triggerKeys, contains('cold'));
      expect(S.triggerKeys, contains('stress'));
      expect(S.triggerKeys, contains('unknown'));
      expect(S.triggerKeys.length, greaterThanOrEqualTo(10));
    });

    test('S.fingerKeys содержит 5 левых и 5 правых пальцев', () {
      expect(S.fingerKeysLeft, hasLength(5));
      expect(S.fingerKeysRight, hasLength(5));
      expect(S.fingerKeysLeft.every((k) => k.endsWith('_l')), isTrue);
      expect(S.fingerKeysRight.every((k) => k.endsWith('_r')), isTrue);
    });

    test('triggerFromKey локализует ru', () {
      expect(S.current.triggerFromKey('cold'), 'Холод');
      expect(S.current.triggerFromKey('stress'), 'Стресс');
    });

    test('fingerFromKey локализует ru', () {
      expect(S.current.fingerFromKey('thumb_l'), 'Большой Л');
      expect(S.current.fingerFromKey('pinky_r'), 'Мизинец П');
    });

    test('fingerFromKey понимает legacy ru-ID', () {
      // Обратная совместимость со старыми записями
      expect(S.current.fingerFromKey('Большой Л'), 'Большой Л');
      expect(S.current.fingerFromKey('Мизинец П'), 'Мизинец П');
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
