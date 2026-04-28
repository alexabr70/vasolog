import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/models/attack_event.dart';
import 'package:vasolog/providers/attack_provider.dart';
import 'package:vasolog/services/location_service.dart';
import 'package:vasolog/services/weather_service.dart';
import 'package:vasolog/utils/constants.dart';
import 'package:vasolog/utils/weather_format.dart';

/// Экран записи / редактирования приступа
class NewAttackScreen extends StatefulWidget {
  const NewAttackScreen({super.key, this.editAttack});
  final AttackEvent? editAttack;

  @override
  State<NewAttackScreen> createState() => _NewAttackScreenState();
}

class _NewAttackScreenState extends State<NewAttackScreen>
    with SingleTickerProviderStateMixin {
  int _severity = 5;
  int _durationMinutes = 0;
  String _colorPhase = 'white';
  final Set<String> _selectedTriggers = {};
  final Set<String> _selectedFingers = {};
  final TextEditingController _notesController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  WeatherData? _weatherData;
  double? _latitude;
  double? _longitude;
  bool _weatherLoading = true;

  /// Триггеры, подсвеченные на основе погоды
  final Set<String> _suggestedTriggers = {};

  /// Shimmer анимация для загрузки погоды
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadWeather();
    if (widget.editAttack != null) {
      _loadFromExisting(widget.editAttack!);
    } else {
      _applySmartDefaults();
    }
  }

  /// Загрузить данные из существующего приступа (редактирование)
  void _loadFromExisting(AttackEvent attack) {
    _severity = attack.severity;
    _durationMinutes = attack.durationMinutes;
    _colorPhase = attack.colorPhase;
    _selectedTriggers.addAll(attack.triggers);
    _selectedFingers.addAll(attack.affectedFingers);
    _photoPath = attack.photoPath;
    if (attack.notes != null) _notesController.text = attack.notes!;
  }

  /// Умные дефолты из последнего приступа
  void _applySmartDefaults() {
    final last = context.read<AttackProvider>().lastAttack;
    if (last != null) {
      _colorPhase = last.colorPhase;
    }
  }

  /// Заполнить всё как в прошлый раз
  void _applyLastAttack() {
    final last = context.read<AttackProvider>().lastAttack;
    if (last == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _severity = last.severity;
      _durationMinutes = last.durationMinutes;
      _colorPhase = last.colorPhase;
      _selectedTriggers.clear();
      _selectedTriggers.addAll(last.triggers);
      _selectedFingers.clear();
      _selectedFingers.addAll(last.affectedFingers);
    });
  }

  Future<void> _loadWeather() async {
    final location = LocationService();
    final position = await location.getCurrentPosition();
    if (position != null) {
      _latitude = position.latitude;
      _longitude = position.longitude;
      final weather = WeatherService();
      final data = await weather.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      if (data != null && mounted) {
        setState(() {
          _weatherData = data;
          _weatherLoading = false;
          _updateSuggestedTriggers(data);
        });
        return;
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.enableGeoLocation),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    if (mounted) setState(() => _weatherLoading = false);
  }

  /// Подсказка триггеров на основе погоды.
  /// Храним стабильные keys, не локализованные строки.
  void _updateSuggestedTriggers(WeatherData data) {
    _suggestedTriggers.clear();
    if (data.temperature <= 10) _suggestedTriggers.add('cold');
    if (data.temperature <= 5) _suggestedTriggers.add('cold_water');
    if (data.windSpeed >= 5) _suggestedTriggers.add('cold');
    if (data.humidity >= 85) _suggestedTriggers.add('stress');
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (photo == null) return;
    // Копируем снимок из временной папки image_picker в постоянный каталог
    // приложения - иначе после переустановки / очистки кэша путь станет
    // битым и при рендере карточки упадёт FileImage.
    try {
      final docs = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docs.path}/photos');
      if (!photosDir.existsSync()) {
        photosDir.createSync(recursive: true);
      }
      final fileName = '${const Uuid().v4()}.jpg';
      final saved = await File(photo.path).copy('${photosDir.path}/$fileName');
      if (mounted) {
        setState(() => _photoPath = saved.path);
      }
    } catch (e) {
      debugPrint('[NewAttack] photo copy failed: $e, fallback to tmp path');
      if (mounted) {
        setState(() => _photoPath = photo.path);
      }
    }
  }

  Future<void> _saveAttack() async {
    setState(() => _isLoading = true);

    final provider = context.read<AttackProvider>();

    // При редактировании удаляем старую запись
    final isEdit = widget.editAttack != null;
    if (isEdit) {
      await provider.deleteAttack(widget.editAttack!.id);
    }

    final event = AttackEvent(
      id: isEdit ? widget.editAttack!.id : const Uuid().v4(),
      timestamp: isEdit ? widget.editAttack!.timestamp : DateTime.now(),
      severity: _severity,
      colorPhase: _colorPhase,
      durationMinutes: _durationMinutes,
      affectedFingers: _selectedFingers.toList(),
      triggers: _selectedTriggers.toList(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      photoPath: _photoPath,
      temperature: _weatherData?.temperature,
      humidity: _weatherData?.humidity,
      pressure: _weatherData?.pressure,
      windSpeed: _weatherData?.windSpeed,
      weatherCode: _weatherData?.weatherCode,
      latitude: _latitude,
      longitude: _longitude,
    );

    try {
      await provider.addAttack(event);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? S.current.attackUpdated : S.current.attackSaved,
            ),
            backgroundColor: Colors.green,
          ),
        );
        // In-app review после 5-го приступа, макс 1 раз
        if (!isEdit) _maybeRequestReview(provider.totalCount);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.current.saveError}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Запросить отзыв после 5-го приступа (макс 1 раз).
  /// На Huawei без GMS isAvailable() = false → открываем AppGallery напрямую.
  Future<void> _maybeRequestReview(int totalAttacks) async {
    if (totalAttacks != 5) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('review_requested') ?? false) return;
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await launchUrl(
        Uri.parse('https://appgallery.huawei.com/app/C117440803'),
        mode: LaunchMode.externalApplication,
      );
    }
    await prefs.setBool('review_requested', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editAttack != null
              ? S.current.editAttack
              : S.current.recordAttack,
        ),
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
            // Погода
            _buildWeatherCard(),
            const SizedBox(height: 8),

            // Кнопка "Как прошлый раз"
            if (context.read<AttackProvider>().lastAttack != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _applyLastAttack,
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: Text(S.current.likeLastTime),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              ),

            // === СЕКЦИЯ 1: Оценка приступа ===
            _SectionCard(
              title: S.current.sectionAssessment,
              icon: Icons.speed_rounded,
              children: [
                // Тяжесть
                Text(
                  S.current.severityRcs,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor(_severity).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_severity',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: severityColor(_severity),
                        ),
                      ),
                    ),
                    const Text('/10', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: S.current.a11ySeveritySlider,
                        value: S.current.a11ySeverityValue(_severity),
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: severityColor(_severity),
                            thumbColor: severityColor(_severity),
                            inactiveTrackColor: severityColor(
                              _severity,
                            ).withValues(alpha: 0.2),
                            overlayColor: severityColor(
                              _severity,
                            ).withValues(alpha: 0.1),
                          ),
                          child: Slider(
                            value: _severity.toDouble(),
                            max: 10,
                            divisions: 10,
                            label: '$_severity',
                            onChanged: (v) {
                              final newVal = v.round();
                              if (newVal != _severity) {
                                HapticFeedback.selectionClick();
                                setState(() => _severity = newVal);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Цвет пальцев
                Text(
                  S.current.fingerColor,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: colorPhases.entries.map((e) {
                    final isSelected = _colorPhase == e.key;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildColorPhaseChip(e.key, e.value, isSelected),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Длительность
                Text(
                  S.current.duration,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$_durationMinutes',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' ${S.current.min}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _durationMinutes.toDouble(),
                        max: 120,
                        divisions: 24,
                        label: '$_durationMinutes мин',
                        onChanged: (v) {
                          final newVal = v.round();
                          if (newVal != _durationMinutes) {
                            HapticFeedback.selectionClick();
                            setState(() => _durationMinutes = newVal);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // === СЕКЦИЯ 2: Триггеры ===
            _SectionCard(
              title: S.current.sectionTriggers,
              icon: Icons.flash_on_rounded,
              trailing: _suggestedTriggers.isNotEmpty
                  ? Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.secondary.withValues(alpha: 0.7),
                    )
                  : null,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _buildSortedTriggers(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // === СЕКЦИЯ 3: Поражённые пальцы ===
            _SectionCard(
              title: S.current.sectionFingers,
              icon: Icons.pan_tool_rounded,
              children: [
                _HandDiagram(
                  selectedFingers: _selectedFingers,
                  onFingerTap: (finger) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (_selectedFingers.contains(finger)) {
                        _selectedFingers.remove(finger);
                      } else {
                        _selectedFingers.add(finger);
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // === СЕКЦИЯ 4: Доп. информация ===
            _SectionCard(
              title: S.current.sectionExtra,
              icon: Icons.note_add_rounded,
              children: [
                // Фото
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(
                        _photoPath == null
                            ? S.current.takePhoto
                            : S.current.retakePhoto,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_photoPath != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      Text(
                        ' ${S.current.photo}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Заметки
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: S.current.notesOptional,
                    hintText: S.current.notesHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Сохранить
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAttack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        S.current.save,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Карточка погоды - чистая, без refresh кнопки и "X мин назад"
  /// (это просто контекст для записи приступа, не интерактивный элемент)
  Widget _buildWeatherCard() {
    if (_weatherData != null) {
      final w = _weatherData!;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Card(
        color: isDark
            ? Colors.blue[900]?.withValues(alpha: 0.3)
            : Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.thermostat, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${formatTemperature(w.temperature)}°C',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${S.current.humidity(formatHumidity(w.humidity))} · ${S.current.windMs(formatWindSpeed(w.windSpeed))}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_weatherLoading) {
      return AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _shimmerBox(24, 24, circular: true),
                  const SizedBox(width: 8),
                  _shimmerBox(60, 20),
                  const SizedBox(width: 12),
                  Expanded(child: _shimmerBox(double.infinity, 14)),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  /// Градиентная плашка для фазы цвета
  Widget _buildColorPhaseChip(String key, String label, bool isSelected) {
    final colors = switch (key) {
      'white' => [const Color(0xFFECEFF1), const Color(0xFFCFD8DC)],
      'blue' => [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
      'red' => [const Color(0xFFEF5350), const Color(0xFFC62828)],
      _ => [const Color(0xFF9E9E9E), const Color(0xFF616161)],
    };
    final textColor = key == 'white' ? Colors.black87 : Colors.white;
    // Короткое название для плашки
    final shortLabel = switch (key) {
      'white' => S.current.phaseWhite,
      'blue' => S.current.phaseBlue,
      'red' => S.current.phaseRed,
      _ => S.current.phaseMixed,
    };

    return GestureDetector(
      onTap: () => setState(() => _colorPhase = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              shortLabel,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: textColor, size: 18),
          ],
        ),
      ),
    );
  }

  /// Триггеры отсортированные: подсказанные погодой - первые.
  /// Работает со стабильными ID; label берётся через S.current.triggerFromKey.
  List<Widget> _buildSortedTriggers() {
    final sorted = [...S.triggerKeys];
    // Подсказанные погодой поднимаем наверх
    sorted.sort((a, b) {
      final aSug = _suggestedTriggers.contains(a) ? 0 : 1;
      final bSug = _suggestedTriggers.contains(b) ? 0 : 1;
      return aSug.compareTo(bSug);
    });

    return sorted.map((triggerKey) {
      final isSelected = _selectedTriggers.contains(triggerKey);
      final isSuggested = _suggestedTriggers.contains(triggerKey);
      return FilterChip(
        label: Text(S.current.triggerFromKey(triggerKey)),
        selected: isSelected,
        selectedColor: AppColors.secondary.withValues(alpha: 0.3),
        backgroundColor: isSuggested
            ? AppColors.secondary.withValues(alpha: 0.1)
            : null,
        side: isSuggested && !isSelected
            ? BorderSide(color: AppColors.secondary.withValues(alpha: 0.5))
            : null,
        avatar: isSuggested && !isSelected
            ? Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.secondary.withValues(alpha: 0.7),
              )
            : null,
        onSelected: (selected) {
          HapticFeedback.selectionClick();
          setState(() {
            if (selected) {
              _selectedTriggers.add(triggerKey);
            } else {
              _selectedTriggers.remove(triggerKey);
            }
          });
        },
      );
    }).toList();
  }

  /// Shimmer-блок для скелетона загрузки
  Widget _shimmerBox(double width, double height, {bool circular = false}) {
    final progress = _shimmerController.value;
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;
    // Плавный блик слева направо
    final t = (progress * 3 - 1).clamp(0.0, 1.0);
    final color = Color.lerp(
      baseColor,
      highlightColor,
      t < 0.5 ? t * 2 : 2 - t * 2,
    )!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(circular ? height / 2 : 4),
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

/// Секция-карточка с заголовком и иконкой
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Интерактивная визуальная схема рук для выбора пальцев
class _HandDiagram extends StatelessWidget {
  const _HandDiagram({
    required this.selectedFingers,
    required this.onFingerTap,
  });
  final Set<String> selectedFingers;
  final ValueChanged<String> onFingerTap;

  @override
  Widget build(BuildContext context) {
    // Convention: thumbs наружу (observer/back-of-hand view).
    // Исходный PNG это правая рука с thumb слева -> для "Left" column
    // оставляем AS-IS (thumb слева), для "Right" mirror (thumb справа).
    // Вертикальный layout: каждая рука занимает полную ширину карточки.
    // Это даёт рукам в 2x больший размер для удобства попадания пальцем,
    // ценой немного большей вертикальной прокрутки.
    return Column(
      children: [
        // Левая рука - без зеркалирования (thumb слева, наружу)
        _HandVisual(
          label: S.current.leftHand,
          fingers: S.fingerKeysLeft,
          selectedFingers: selectedFingers,
          onFingerTap: onFingerTap,
          mirrored: false,
        ),
        const SizedBox(height: 16),
        // Правая рука - зеркалирование (thumb справа, наружу)
        _HandVisual(
          label: S.current.rightHand,
          fingers: S.fingerKeysRight,
          selectedFingers: selectedFingers,
          onFingerTap: onFingerTap,
          mirrored: true,
        ),
      ],
    );
  }
}

/// Визуальная рука: PNG-иллюстрация (сгенерирована Gemini 2.5 Flash Image)
/// с невидимыми тап-таргетами над каждым пальцем. Для левой руки
/// используется горизонтальное зеркалирование через Transform.
class _HandVisual extends StatelessWidget {
  const _HandVisual({
    required this.label,
    required this.fingers,
    required this.selectedFingers,
    required this.onFingerTap,
    required this.mirrored,
  });
  final String label;
  final List<String> fingers;
  final Set<String> selectedFingers;
  final ValueChanged<String> onFingerTap;
  final bool mirrored;

  /// Нормализованные позиции кончиков пальцев на hand_right.png (1024x1024).
  /// Порядок: [большой, указат., средний, безымян., мизинец]
  /// Откалибровано через pixel analysis: thumb - leftmost dark pixel в lower
  /// half, остальные - локальные минимумы top-row.
  /// Проверено визуально в screenshots/hand_with_marks2.png.
  static const List<Offset> _rightFingerTips = [
    Offset(0.224, 0.44), // Большой (leftmost тип)
    Offset(0.438, 0.16), // Указательный
    Offset(0.575, 0.13), // Средний (самый высокий)
    Offset(0.672, 0.18), // Безымянный
    Offset(0.774, 0.31), // Мизинец
  ];

  @override
  Widget build(BuildContext context) {
    final selected = List.generate(
      5,
      (i) => selectedFingers.contains(fingers[i]),
    );
    final hasSelection = selected.any((s) => s);

    // Для левой руки зеркалим позиции пальцев по X
    final tips = mirrored
        ? _rightFingerTips.map((o) => Offset(1 - o.dx, o.dy)).toList()
        : _rightFingerTips;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            // Картинка квадратная - умеренный размер (280px max)
            // чтобы тап-таргеты не перекрывали соседние пальцы
            final w = constraints.maxWidth;
            final imgSize = w.clamp(200.0, 280.0);

            return Column(
              children: [
                SizedBox(
                  width: imgSize,
                  height: imgSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // База - сама картинка руки (зеркалим для левой)
                      Positioned.fill(
                        child: Transform.scale(
                          scaleX: mirrored ? -1.0 : 1.0,
                          child: Image.asset(
                            'assets/images/hand_right.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // L/R маркер в центре ладони - убирает двусмысленность
                      // (какая рука какой соответствует)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: imgSize * 0.58,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              mirrored ? 'R' : 'L',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Селект-кольца поверх выбранных пальцев
                      // Размер 12% ширины - не перекрывают соседние пальцы
                      ...List.generate(5, (i) {
                        if (!selected[i]) return const SizedBox.shrink();
                        final tip = tips[i];
                        final cx = tip.dx * imgSize;
                        final cy = tip.dy * imgSize;
                        final ringSize = (imgSize * 0.12).clamp(28.0, 48.0);
                        return Positioned(
                          left: cx - ringSize / 2,
                          top: cy - ringSize / 2,
                          width: ringSize,
                          height: ringSize,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.phaseBlue.withValues(
                                  alpha: 0.4,
                                ),
                                border: Border.all(
                                  color: AppColors.phaseBlue,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.phaseBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      // Тап-таргеты над каждым пальцем - 44-60px
                      // (минимум a11y без перекрытия соседних пальцев)
                      ...List.generate(5, (i) {
                        final tip = tips[i];
                        final cx = tip.dx * imgSize;
                        final cy = tip.dy * imgSize;
                        final tapSize = (imgSize * 0.17).clamp(44.0, 60.0);
                        return Positioned(
                          left: cx - tapSize / 2,
                          top: cy - tapSize / 2,
                          width: tapSize,
                          height: tapSize,
                          child: Semantics(
                            button: true,
                            label: S.current.a11yFingerButton(
                              S.current.fingerFromKey(fingers[i]),
                            ),
                            selected: selected[i],
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onFingerTap(fingers[i]),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                if (!hasSelection)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      S.current.tapHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
