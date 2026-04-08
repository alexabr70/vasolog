import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/deep_link_service.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'report_screen.dart';
import 'about_screen.dart';
import 'new_attack_screen.dart';

/// Главная оболочка с Bottom Navigation + центральный FAB
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;
  StreamSubscription<DeepLinkAction>? _deepLinkSub;

  final _pages = const [
    HomeScreen(),
    HistoryScreen(),
    ReportScreen(),
    AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    // Анимация появления FAB
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fabController.forward();
    });

    // Deep linking: push уведомление → конкретный экран
    _deepLinkSub = DeepLinkService().actions.listen(_handleDeepLink);

    // Проверить pending action от холодного старта
    final pending = DeepLinkService().consumePendingAction();
    if (pending != null) {
      // Дождаться первого кадра перед навигацией
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleDeepLink(pending);
      });
    }
  }

  void _handleDeepLink(DeepLinkAction action) {
    if (!mounted) return;
    switch (action) {
      case DeepLinkAction.newAttack:
        _openNewAttack();
      case DeepLinkAction.history:
        setState(() => _currentIndex = 1);
      case DeepLinkAction.home:
        setState(() => _currentIndex = 0);
    }
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _openNewAttack() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const NewAttackScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.large(
          onPressed: _openNewAttack,
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 12,
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Главная',
              isActive: _currentIndex == 0,
              onTap: () => _onTabTap(0),
            ),
            _NavItem(
              icon: Icons.timeline_rounded,
              label: 'История',
              isActive: _currentIndex == 1,
              onTap: () => _onTabTap(1),
            ),
            const SizedBox(width: 48), // Пространство для FAB
            _NavItem(
              icon: Icons.picture_as_pdf_rounded,
              label: 'Отчёт',
              isActive: _currentIndex == 2,
              onTap: () => _onTabTap(2),
            ),
            _NavItem(
              icon: Icons.info_outline_rounded,
              label: 'Инфо',
              isActive: _currentIndex == 3,
              onTap: () => _onTabTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? AppColors.primary : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
