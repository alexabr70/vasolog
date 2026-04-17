import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/models/attack_event.dart';
import 'package:vasolog/providers/attack_provider.dart';
import 'package:vasolog/providers/locale_provider.dart';
import 'package:vasolog/screens/main_shell.dart';
import 'package:vasolog/screens/onboarding_screen.dart';
import 'package:vasolog/services/deep_link_service.dart';
import 'package:vasolog/services/notification_service.dart';
import 'package:vasolog/services/storage_service.dart';
import 'package:vasolog/services/widget_service.dart';
import 'package:vasolog/utils/constants.dart';

/// Флаг для наполнения БД демо-данными при первом запуске (для скриншотов).
/// Включается через: flutter build apk --dart-define=DEMO_DATA=true
const _demoData = bool.fromEnvironment('DEMO_DATA');

void main() async {
  // Профайл старта для диагностики долгого splash
  final startStopwatch = Stopwatch()..start();
  void logStep(String step) {
    debugPrint('[startup] +${startStopwatch.elapsedMilliseconds}ms $step');
  }

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(); // все локали для DateFormat с locale-параметром
  // Раньше был FlutterNativeSplash.preserve() + remove в post-frame callback,
  // но это удерживало native blue splash до первого кадра Flutter (+800ms).
  // Без preserve - native splash исчезает как только Flutter engine готов,
  // пользователь сразу видит Flutter _AppLoadingScreen с анимацией.
  logStep('flutter engine ready');

  // Локализация синхронно (дефолт - системная локаль), язык из prefs
  // подхватится позже в _postFrameInit после async загрузки
  S.init(ui.PlatformDispatcher.instance.locale.languageCode);

  // Создаём провайдеры БЕЗ инициализации хранилища - это быстро.
  // Реальный Hive.init() запустится после первого кадра чтобы не блокировать splash.
  final storage = StorageService();
  final attackProvider = AttackProvider(storage);
  final localeProvider = LocaleProvider(null);

  runApp(
    VasoLogApp(
      storage: storage,
      attackProvider: attackProvider,
      localeProvider: localeProvider,
    ),
  );
  logStep('runApp called');

  // Запускаем async init после первого кадра
  WidgetsBinding.instance.addPostFrameCallback((_) {
    logStep('first frame');
    // Критический и отложенный init - всё после первого кадра
    unawaited(_postFrameInit(attackProvider, localeProvider, logStep));
  });
}

/// Инициализация после первого кадра: Hive, prefs, язык, сервисы.
/// UI уже виден с пустым состоянием - данные подтянутся через notifyListeners.
Future<void> _postFrameInit(
  AttackProvider attackProvider,
  LocaleProvider localeProvider,
  void Function(String) logStep,
) async {
  // Hive + данные приступов - самое долгое (keystore access)
  try {
    await attackProvider.init();
    logStep('attack provider (Hive) init done');
    if (_demoData && attackProvider.totalCount == 0) {
      await _seedDemoData(attackProvider);
      logStep('demo data seeded');
    }
  } catch (e) {
    debugPrint('AttackProvider init error: $e');
  }

  // Язык из prefs (если юзер его менял)
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(LocaleProvider.prefsKey);
    if (saved != null && saved != localeProvider.languageCode) {
      await localeProvider.setLanguage(saved);
    }
    logStep('locale prefs loaded');
  } catch (e) {
    debugPrint('Locale load error: $e');
  }

  // Онбординг - не блокирует UI; если надо показать, навигация
  // произойдёт через MainShell (AppState)
  // (текущая реализация показывает onboarding только при !onboarding_done
  //  - см. передачу showOnboarding в VasoLogApp. Пока упрощение: онбординг
  //  покажется при следующем запуске если ещё не видели)

  // Отложенная инициализация сервисов (не критично для UI)
  await _initDeferredServices(logStep);
}

/// Засеять БД конверсионными демо-данными для скриншотов.
/// 6 приступов за последние 2 недели с разными severity/phase/triggers.
/// Использует стабильные keys - корректно локализуется на любом языке.
Future<void> _seedDemoData(AttackProvider provider) async {
  const uuid = Uuid();
  final now = DateTime.now();
  final seeds = [
    (daysAgo: 0, hour: 9, severity: 6, phase: 'white',
     triggers: ['cold', 'stress'], fingers: ['index_l', 'middle_l', 'ring_l'],
     duration: 12, temp: 2.5, hum: 78.0, code: 3),
    (daysAgo: 1, hour: 14, severity: 4, phase: 'blue',
     triggers: ['cold_water'], fingers: ['thumb_r', 'index_r'],
     duration: 8, temp: 4.0, hum: 65.0, code: 0),
    (daysAgo: 2, hour: 20, severity: 7, phase: 'red',
     triggers: ['cold', 'caffeine'], fingers: ['index_l', 'middle_l', 'ring_l', 'pinky_l'],
     duration: 18, temp: -1.0, hum: 85.0, code: 71),
    (daysAgo: 4, hour: 8, severity: 3, phase: 'white',
     triggers: ['stress'], fingers: ['middle_r'],
     duration: 5, temp: 6.0, hum: 70.0, code: 2),
    (daysAgo: 7, hour: 18, severity: 5, phase: 'blue',
     triggers: ['cold', 'vibration'], fingers: ['thumb_l', 'index_l'],
     duration: 10, temp: 1.0, hum: 82.0, code: 61),
    (daysAgo: 10, hour: 11, severity: 8, phase: 'red',
     triggers: ['cold', 'emotions'], fingers: ['index_r', 'middle_r', 'ring_r'],
     duration: 22, temp: -3.0, hum: 90.0, code: 75),
  ];
  for (final s in seeds) {
    final ts = now.subtract(Duration(days: s.daysAgo));
    final timestamp = DateTime(ts.year, ts.month, ts.day, s.hour, 15);
    await provider.addAttack(
      AttackEvent(
        id: uuid.v4(),
        timestamp: timestamp,
        severity: s.severity,
        colorPhase: s.phase,
        durationMinutes: s.duration,
        affectedFingers: s.fingers,
        triggers: s.triggers,
        temperature: s.temp,
        humidity: s.hum,
        pressure: 1013,
        windSpeed: 3,
        weatherCode: s.code,
      ),
    );
  }
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
    required this.attackProvider,
    required this.localeProvider,
    super.key,
  });
  final StorageService storage;
  final AttackProvider attackProvider;
  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AttackProvider>.value(value: attackProvider),
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
          home: const _AppRoot(),
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    // Используем системный шрифт (Roboto на Android, SF на iOS).
    // GoogleFonts.interTextTheme() триггерит ленивую HTTP-загрузку на первом
    // кадре, что делает splash ощутимо длиннее.
    final textTheme = ThemeData.light().textTheme;
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
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ThemeData _darkTheme() {
    final textTheme = ThemeData.dark().textTheme;
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
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Корневой widget: показывает loading screen пока AttackProvider не готов,
/// затем - MainShell (или Onboarding на первом запуске).
/// Это заменяет blue native splash на анимированный Flutter-экран
/// с индикатором загрузки.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlag();
  }

  Future<void> _loadOnboardingFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(
          () => _onboardingDone = prefs.getBool('onboarding_done') ?? false,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _onboardingDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttackProvider>(
      builder: (context, provider, _) {
        // Ждём и Hive, и загрузку флага онбординга
        if (!provider.isReady || _onboardingDone == null) {
          return const _AppLoadingScreen();
        }
        return _onboardingDone! ? const MainShell() : const OnboardingScreen();
      },
    );
  }
}

/// Экран загрузки с градиентом, логотипом, пульсирующей анимацией и
/// текстом "Загрузка данных". Показывается пока Hive инициализируется.
class _AppLoadingScreen extends StatefulWidget {
  const _AppLoadingScreen();

  @override
  State<_AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<_AppLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Пульсирующий логотип
              ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.ac_unit_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Название приложения
              const Text(
                'VasoLog',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              // Линейный индикатор загрузки
              SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
