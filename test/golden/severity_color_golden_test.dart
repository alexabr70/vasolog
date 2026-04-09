// Golden tests: визуальная регрессия цветов тяжести
// Запуск: flutter test test/golden/
// Обновление эталонов: flutter test --update-goldens test/golden/

import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:vasolog/utils/constants.dart';

void main() {
  testGoldens('Severity colors - все значения 0..10', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
      ..addScenario('Severity 0', _severityBox(0))
      ..addScenario('Severity 1', _severityBox(1))
      ..addScenario('Severity 2', _severityBox(2))
      ..addScenario('Severity 3', _severityBox(3))
      ..addScenario('Severity 4', _severityBox(4))
      ..addScenario('Severity 5', _severityBox(5))
      ..addScenario('Severity 6', _severityBox(6))
      ..addScenario('Severity 7', _severityBox(7))
      ..addScenario('Severity 8', _severityBox(8))
      ..addScenario('Severity 9', _severityBox(9))
      ..addScenario('Severity 10', _severityBox(10));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'severity_colors_grid');
  });
}

Widget _severityBox(int severity) {
  return Container(
    width: 100,
    height: 100,
    color: severityColor(severity),
    child: Center(
      child: Text(
        '$severity',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
