import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Сервис для обновления home screen widget
class WidgetService {
  static const _androidWidgetName = 'VasoLogWidgetProvider';
  static const _iosWidgetName = 'VasoLogWidget';
  static const _appGroupId = 'group.com.vasolog.vasolog';

  /// Инициализация
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (e) {
      debugPrint('HomeWidget init error: $e');
    }
  }

  /// Обновить данные виджета
  static Future<void> update({
    required int daysSinceLastAttack,
    required int weeklyCount,
    required double avgSeverity,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData('streak', daysSinceLastAttack),
        HomeWidget.saveWidgetData('weekly', weeklyCount),
        HomeWidget.saveWidgetData('severity', avgSeverity.toStringAsFixed(1)),
      ]);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      debugPrint('Widget update error: $e');
    }
  }
}
