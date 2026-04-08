import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/attack_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация хранилища
  final storage = StorageService();
  await storage.init();

  runApp(VasoLogApp(storage: storage));
}

class VasoLogApp extends StatelessWidget {
  final StorageService storage;

  const VasoLogApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttackProvider(storage),
      child: MaterialApp(
        title: 'VasoLog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          brightness: Brightness.light,
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
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
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
