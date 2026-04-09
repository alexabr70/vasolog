import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/providers/attack_provider.dart';
import 'package:vasolog/providers/locale_provider.dart';
import 'package:vasolog/screens/main_shell.dart';
import 'package:vasolog/screens/onboarding_screen.dart';
import 'package:vasolog/services/deep_link_service.dart';
import 'package:vasolog/services/notification_service.dart';
import 'package:vasolog/services/storage_service.dart';
import 'package:vasolog/services/widget_service.dart';
import 'package:vasolog/utils/constants.dart';

void main() async {
  // Профайл старта для диагностики долгого splash
  final startStopwatch = Stopwatch()..start();
  void logStep(String step) {
    debugPrint('[startup] +${startStopwatch.elapsedMilliseconds}ms $step');
  }

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  logStep('splash preserved');

  // Запрет загрузки шрифтов из сети (ускоряет первый запуск)
  GoogleFonts.config.allowRuntimeFetching = false;

  // КРИТИЧЕСКИЙ ПУТЬ: только то, что нужно для первого кадра
  // (Hive нужен AttackProvider, SharedPreferences - для onboarding flag + язык)
  StorageService? storage;
  var onboardingDone = false;
  LocaleProvider? localeProvider;

  try {
    storage = StorageService();
    await storage.init();
    logStep('storage init done');

    final prefs = await SharedPreferences.getInstance();
    onboardingDone = prefs.getBool('onboarding_done') ?? false;
    localeProvider = await LocaleProvider.load(prefs);
    logStep('prefs read done');
  } catch (e) {
    debugPrint('Init error: $e');
    // Гарантируем что storage инициализирован даже после ошибки
    storage ??= StorageService();
    try {
      await storage.init();
    } catch (_) {
      // Hive init провалился повторно - приложение запустится, но без данных
      debugPrint('Storage init retry failed');
    }
  }

  // Fallback если prefs сломались: инициализируем язык по системной локали
  if (localeProvider == null) {
    S.init(ui.PlatformDispatcher.instance.locale.languageCode);
    localeProvider = LocaleProvider(null);
  }

  runApp(
    VasoLogApp(
      storage: storage,
      showOnboarding: !onboardingDone,
      localeProvider: localeProvider,
    ),
  );
  logStep('runApp called');

  // Убираем splash сразу после первого кадра (не до runApp!)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
    logStep('splash removed (first frame)');

    // ОТЛОЖЕННАЯ ИНИЦИАЛИЗАЦИЯ: всё, что не блокирует первый UI
    // Уведомления, deep links, home widget - могут подождать
    unawaited(_initDeferredServices(logStep));
  });
}

/// Сервисы, которые инициализируются после первого кадра
/// (не блокируют splash и не видны пользователю на старте)
Future<void> _initDeferredServices(void Function(String) logStep) async {
  try {
    await NotificationService().init();
    logStep('notifications init done');
  } catch (e) {
    debugPrint('Notifications init error: $e');
  }
  try {
    await DeepLinkService().init();
    logStep('deep links init done');
  } catch (e) {
    debugPrint('Deep links init error: $e');
  }
  try {
    await WidgetService.init();
    logStep('widget service init done');
  } catch (e) {
    debugPrint('Widget service init error: $e');
  }
}

class VasoLogApp extends StatelessWidget {

  const VasoLogApp({
    required this.storage,
    required this.showOnboarding,
    required this.localeProvider,
    super.key,
  });
  final StorageService storage;
  final bool showOnboarding;
  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttackProvider(storage)),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) => MaterialApp(
          // key меняется при смене языка -> MaterialApp полностью пересобирается,
          // что сбрасывает кеши локализации и обновляет S.current во всех экранах
          key: ValueKey('app-${locale.effectiveCode}'),
          locale: Locale(locale.effectiveCode),
        title: 'VasoLog',
        debugShowCheckedModeBanner: false,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ru'),
          Locale('de'),
          Locale('fr'),
          Locale('es'),
          Locale('pt'),
          Locale('it'),
          Locale('sv'),
          Locale('fi'),
          Locale('nb'),
          Locale('da'),
          Locale('nl'),
          Locale('pl'),
          Locale('cs'),
          Locale('hu'),
          Locale('uk'),
          Locale('ja'),
          Locale('ko'),
        ],
          home: showOnboarding ? const OnboardingScreen() : const MainShell(),
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      colorSchemeSeed: AppColors.primary,
      brightness: Brightness.light,
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      colorSchemeSeed: AppColors.primary,
      brightness: Brightness.dark,
      useMaterial3: true,
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
