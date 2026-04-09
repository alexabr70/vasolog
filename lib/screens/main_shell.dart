import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/screens/about_screen.dart';
import 'package:vasolog/screens/history_screen.dart';
import 'package:vasolog/screens/home_screen.dart';
import 'package:vasolog/screens/new_attack_screen.dart';
import 'package:vasolog/screens/report_screen.dart';
import 'package:vasolog/services/deep_link_service.dart';
import 'package:vasolog/utils/constants.dart';

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
    _fabScale = Tween<double>(begin: 0, end: 1).animate(
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
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NewAttackScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
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
      // FAB скрыт на экранах Report (2) и About (3) - там он перекрывает
      // полезный контент (например кнопку "Создать PDF" на экране отчёта)
      floatingActionButton: (_currentIndex == 2 || _currentIndex == 3)
          ? null
          : Semantics(
              button: true,
              label: S.current.a11yAddAttack,
              child: ScaleTransition(
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
        height: 72,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.dashboard_rounded,
                label: S.current.tabHome,
                isActive: _currentIndex == 0,
                onTap: () => _onTabTap(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.timeline_rounded,
                label: S.current.tabHistory,
                isActive: _currentIndex == 1,
                onTap: () => _onTabTap(1),
              ),
            ),
            const SizedBox(width: 80), // Пространство для FAB (96px + отступы)
            Expanded(
              child: _NavItem(
                icon: Icons.picture_as_pdf_rounded,
                label: S.current.tabReport,
                isActive: _currentIndex == 2,
                onTap: () => _onTabTap(2),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.info_outline_rounded,
                label: S.current.tabInfo,
                isActive: _currentIndex == 3,
                onTap: () => _onTabTap(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? AppColors.primary : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
