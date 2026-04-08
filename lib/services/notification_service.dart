import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'deep_link_service.dart';

/// Обработчик нажатия на уведомление (top-level для изоляции)
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse response) {
  // Передаём payload в DeepLinkService для навигации
  DeepLinkService().handleNotificationPayload(response.payload);
}

/// Сервис локальных уведомлений
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const _channelId = 'vasolog_reminders';
  static const _channelName = 'Напоминания VasoLog';

  // ID уведомлений
  static const _weeklyReminderId = 100;
  static const _inactivityReminderId = 101;

  /// Инициализация плагина + timezone
  Future<void> init() async {
    if (_initialized) return;

    // Инициализация timezone
    tz_data.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Moscow'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    _initialized = true;

    // Если уведомления были включены ранее - перепланировать после перезапуска
    final enabled = await isEnabled;
    if (enabled) {
      await _scheduleAll();
    }
  }

  /// Запросить разрешение на уведомления
  Future<bool> requestPermission() async {
    try {
      // Android 13+ - запрос runtime permission
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }

      // iOS - запрос через сам плагин
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
    return false;
  }

  /// Запланировать все уведомления
  Future<void> _scheduleAll() async {
    try {
      await scheduleWeeklyReminder();
      await scheduleInactivityReminder();
    } catch (e) {
      debugPrint('Schedule error: $e');
    }
  }

  /// Запланировать ежедневное напоминание (12:30)
  Future<void> scheduleWeeklyReminder() async {
    // Отменяем старое перед перепланированием
    await _plugin.cancel(_weeklyReminderId);

    await _plugin.zonedSchedule(
      _weeklyReminderId,
      'Как ваши руки?',
      'Запишите состояние, если был приступ',
      _nextInstanceOfTime(12, 30),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Ежедневные напоминания о записи состояния',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: const DefaultStyleInformation(true, true),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );
  }

  /// Запланировать уведомление о неактивности (через 3 дня)
  Future<void> scheduleInactivityReminder() async {
    await _plugin.cancel(_inactivityReminderId);

    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));

    await _plugin.zonedSchedule(
      _inactivityReminderId,
      'Давно не было записей',
      'Всё хорошо? Если был приступ - запишите его',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Напоминание при отсутствии записей',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'inactivity_reminder',
    );
  }

  /// Отменить все уведомления
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Включены ли уведомления
  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  /// Включить/выключить уведомления
  /// Возвращает true если успешно включено, false если permission denied или выключено
  Future<bool> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    if (enabled) {
      final granted = await requestPermission();
      if (!granted) {
        // Permission denied - не сохраняем как enabled
        return false;
      }
      await prefs.setBool('notifications_enabled', true);
      await _scheduleAll();
      return true;
    } else {
      await prefs.setBool('notifications_enabled', false);
      await cancelAll();
      return false;
    }
  }

  /// Сбросить таймер неактивности (вызывать после каждой записи приступа)
  Future<void> resetInactivityTimer() async {
    final enabled = await isEnabled;
    if (enabled) {
      try {
        await scheduleInactivityReminder();
      } catch (e) {
        debugPrint('Reset inactivity timer error: $e');
      }
    }
  }

  /// Следующий экземпляр указанного времени (сегодня или завтра)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
