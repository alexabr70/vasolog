import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/providers/locale_provider.dart';
import 'package:vasolog/utils/constants.dart';

/// Экран настроек приложения.
/// Сейчас содержит только выбор языка, но сюда будут добавляться
/// будущие опции (тема, формат даты, единицы температуры и т.п.)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.settings),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.language_rounded,
                color: AppColors.primary,
              ),
              title: Text(S.current.language),
              subtitle: Text(_currentLanguageLabel(context)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _openLanguagePicker(context),
            ),
          ),
        ],
      ),
    );
  }

  String _currentLanguageLabel(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final code = provider.languageCode;
    if (code == null) return S.current.systemDefault;
    return S.supportedLanguages[code] ?? code;
  }

  Future<void> _openLanguagePicker(BuildContext context) async {
    final provider = context.read<LocaleProvider>();
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final entries = S.supportedLanguages.entries.toList();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  S.current.selectLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Системный язык (null)
                    RadioListTile<String?>(
                      title: Text(S.current.systemDefault),
                      value: null,
                      // Явный sentinel для "текущее значение null"
                      // ignore: deprecated_member_use
                      groupValue: provider.languageCode,
                      // ignore: deprecated_member_use
                      onChanged: (v) =>
                          Navigator.pop(sheetContext, _SentinelNull.value),
                    ),
                    const Divider(height: 1),
                    ...entries.map(
                      (e) => RadioListTile<String?>(
                        title: Text(e.value),
                        value: e.key,
                        // ignore: deprecated_member_use
                        groupValue: provider.languageCode,
                        // ignore: deprecated_member_use
                        onChanged: (v) => Navigator.pop(sheetContext, v),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    // Результат: строка-код языка, либо sentinel означающий "вернуть null"
    if (selected == _SentinelNull.value) {
      await provider.setLanguage(null);
    } else if (selected != null) {
      await provider.setLanguage(selected);
    }
  }
}

/// Sentinel для отличия "отмена bottom sheet" (null) от "выбран системный" (тоже null).
class _SentinelNull {
  static const String value = '__system__';
}
