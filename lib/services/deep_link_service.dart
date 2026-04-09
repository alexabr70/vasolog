import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Действия по deep link / notification payload
enum DeepLinkAction {
  newAttack, // Открыть экран записи приступа
  history, // Открыть историю
  home, // Открыть главную
}

/// Сервис deep linking (app_links + notification payloads)
class DeepLinkService {
  factory DeepLinkService() => _instance;
  DeepLinkService._();
  static final DeepLinkService _instance = DeepLinkService._();

  final _appLinks = AppLinks();
  final _actionController = StreamController<DeepLinkAction>.broadcast();
  bool _initialized = false;
  StreamSubscription<Uri>? _linkSub;

  /// Действие, полученное до появления подписчика (холодный старт)
  DeepLinkAction? _pendingAction;

  /// Стрим действий для навигации
  Stream<DeepLinkAction> get actions => _actionController.stream;

  /// Pending action при холодном старте (проверить при первой подписке)
  DeepLinkAction? consumePendingAction() {
    final action = _pendingAction;
    _pendingAction = null;
    return action;
  }

  /// Инициализация - слушать deep links
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Обработка ссылки при холодном старте
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, buffered: true);
      }
    } catch (e) {
      debugPrint('Initial deep link error: $e');
    }

    // Обработка ссылок когда приложение уже запущено
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('Deep link stream error: $e'),
    );
  }

  /// Обработка notification payload (из push уведомлений)
  void handleNotificationPayload(String? payload) {
    if (payload == null) return;
    switch (payload) {
      case 'daily_reminder':
      case 'inactivity_reminder':
        _emitAction(DeepLinkAction.newAttack);
      default:
        debugPrint('Unknown notification payload: $payload');
    }
  }

  /// Обработка URI
  void _handleUri(Uri uri, {bool buffered = false}) {
    final path = uri.host.isNotEmpty ? uri.host : uri.pathSegments.firstOrNull;
    final action = switch (path) {
      'new' || 'new-attack' => DeepLinkAction.newAttack,
      'history' => DeepLinkAction.history,
      _ => DeepLinkAction.home,
    };

    if (buffered) {
      // При холодном старте: сохраняем + отправляем в стрим
      _pendingAction = action;
    }
    _emitAction(action);
  }

  void _emitAction(DeepLinkAction action) {
    if (!_actionController.isClosed) {
      _actionController.add(action);
    }
  }

  void dispose() {
    _linkSub?.cancel();
    _actionController.close();
  }
}
