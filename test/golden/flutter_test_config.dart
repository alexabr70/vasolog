// Конфиг для golden tests - единый шрифт чтобы избежать расхождений между OS.
// Загружается автоматически при запуске тестов в этой директории.
// https://pub.dev/packages/golden_toolkit
import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return GoldenToolkit.runWithConfiguration(
    () async {
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      // Принудительно обновляем goldens только на CI с флагом
      skipGoldenAssertion: () => false,
      enableRealShadows: true,
    ),
  );
}
