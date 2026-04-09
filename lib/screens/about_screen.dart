import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../l10n/app_strings.dart';

/// Экран "О приложении" с medical disclaimer и privacy policy
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    final enabled = await NotificationService().isEnabled;
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _toggleNotifications(bool value) async {
    final result = await NotificationService().setEnabled(value);
    if (mounted) {
      setState(() => _notificationsEnabled = result);
      if (value && !result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.current.notificationPermissionDenied),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.aboutTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Логотип и версия
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.ac_unit_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text('VasoLog', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('${S.current.version} 1.1.0', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Medical Disclaimer
            _buildSection(
              S.current.medicalDisclaimer,
              Icons.medical_information_rounded,
              Colors.red,
              'VasoLog НЕ является медицинским устройством. '
              'Приложение не предназначено для диагностики, лечения '
              'или профилактики каких-либо заболеваний.\n\n'
              'Данные приложения носят исключительно информационный '
              'характер и не заменяют консультацию врача.\n\n'
              'При появлении симптомов обратитесь к ревматологу.',
            ),
            const SizedBox(height: 16),

            // Privacy Policy
            _buildSection(
              S.current.privacyPolicy,
              Icons.privacy_tip_rounded,
              AppColors.primary,
              'Какие данные собираются:\n'
              '- Записи о приступах (хранятся локально на устройстве)\n'
              '- Геолокация (только для определения погоды, не передаётся третьим лицам)\n'
              '- Фотографии (хранятся локально на устройстве)\n\n'
              'Куда передаются данные:\n'
              '- OpenWeatherMap API: передаются только координаты для получения погоды\n'
              '- Никакие персональные или медицинские данные не передаются на серверы\n\n'
              'Хранение данных:\n'
              '- Все данные хранятся исключительно на вашем устройстве\n'
              '- Вы можете удалить все данные удалив приложение\n'
              '- PDF-отчёты создаются локально',
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://vasolog-app.github.io/privacy_policy.html'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(S.current.fullPrivacyPolicy),
              ),
            ),
            const SizedBox(height: 16),

            // Ваши права
            _buildSection(
              S.current.yourRights,
              Icons.gavel_rounded,
              Colors.teal,
              '- Вы можете экспортировать свои данные через PDF-отчёты\n'
              '- Вы можете удалить все данные, удалив приложение\n'
              '- Вы можете отозвать разрешения в настройках устройства\n'
              '- Приложение работает полностью офлайн (кроме погоды)',
            ),
            const SizedBox(height: 16),

            // Уведомления
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_rounded, size: 20, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.current.reminders, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(S.current.dailyAt1230, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeTrackColor: AppColors.secondary.withValues(alpha: 0.5),
                      activeThumbColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Контакты
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(S.current.feedback, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => launchUrl(
                        Uri(scheme: 'mailto', path: 'vasolog.app@gmail.com',
                            queryParameters: {'subject': 'VasoLog - Обратная связь'}),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'vasolog.app@gmail.com',
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: Colors.grey[700], height: 1.5)),
          ],
        ),
      ),
    );
  }
}
