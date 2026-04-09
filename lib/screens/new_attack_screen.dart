import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
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

class _NewAttackScreenState extends State<NewAttackScreen> with SingleTickerProviderStateMixin {
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

  /// Подсказка триггеров на основе погоды
  void _updateSuggestedTriggers(WeatherData data) {
    _suggestedTriggers.clear();
    if (data.temperature <= 10) _suggestedTriggers.add('Холод');
    if (data.temperature <= 5) _suggestedTriggers.add('Холодная вода');
    if (data.windSpeed >= 5) _suggestedTriggers.add('Холод');
    if (data.humidity >= 85) _suggestedTriggers.add('Стресс');
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() => _photoPath = photo.path);
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
      weatherDescription: _weatherData?.description,
      latitude: _latitude,
      longitude: _longitude,
    );

    try {
      await provider.addAttack(event);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? S.current.attackUpdated : S.current.attackSaved),
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

  /// Запросить отзыв после 5-го приступа (макс 1 раз)
  Future<void> _maybeRequestReview(int totalAttacks) async {
    if (totalAttacks != 5) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('review_requested') ?? false) return;
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
      await prefs.setBool('review_requested', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(widget.editAttack != null ? S.current.editAttack : S.current.recordAttack),
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
                  style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                ),
              ),

            // === СЕКЦИЯ 1: Оценка приступа ===
            _SectionCard(
              title: S.current.sectionAssessment,
              icon: Icons.speed_rounded,
              children: [
                // Тяжесть
                Text(S.current.severityRcs, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor(_severity).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$_severity', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: severityColor(_severity))),
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
                            inactiveTrackColor: severityColor(_severity).withValues(alpha: 0.2),
                            overlayColor: severityColor(_severity).withValues(alpha: 0.1),
                          ),
                          child: Slider(
                            value: _severity.toDouble(), max: 10, divisions: 10,
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
                Text(S.current.fingerColor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                Text(S.current.duration, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('$_durationMinutes', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(' ${S.current.min}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _durationMinutes.toDouble(), max: 120, divisions: 24,
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
                  ? Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary.withValues(alpha: 0.7))
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
                      label: Text(_photoPath == null ? S.current.takePhoto : S.current.retakePhoto),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_photoPath != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      Text(' ${S.current.photo}', style: const TextStyle(fontSize: 13)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(S.current.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Карточка погоды с поддержкой кэша
  Widget _buildWeatherCard() {
    if (_weatherData != null) {
      final w = _weatherData!;
      final cacheLabel = w.isCached ? ' (${S.current.minutesAgo(w.minutesAgo)})' : '';
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Card(
        color: w.isCached
            ? (isDark ? Colors.orange[900]?.withValues(alpha: 0.3) : Colors.orange[50])
            : (isDark ? Colors.blue[900]?.withValues(alpha: 0.3) : Colors.blue[50]),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                w.isCached ? Icons.cached : Icons.thermostat,
                color: w.isCached ? Colors.orange : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                '${formatTemperature(w.temperature)}°C',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${S.current.humidity(formatHumidity(w.humidity))} · ${S.current.windMs(formatWindSpeed(w.windSpeed))}$cacheLabel',
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
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: colors[0].withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          children: [
            Text(shortLabel, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
            if (isSelected) Icon(Icons.check_circle, color: textColor, size: 18),
          ],
        ),
      ),
    );
  }

  /// Триггеры отсортированные: подсказанные погодой - первые
  List<Widget> _buildSortedTriggers() {
    final sorted = [...availableTriggers];
    // Подсказанные погодой поднимаем наверх
    sorted.sort((a, b) {
      final aSug = _suggestedTriggers.contains(a) ? 0 : 1;
      final bSug = _suggestedTriggers.contains(b) ? 0 : 1;
      return aSug.compareTo(bSug);
    });

    return sorted.map((trigger) {
      final isSelected = _selectedTriggers.contains(trigger);
      final isSuggested = _suggestedTriggers.contains(trigger);
      return FilterChip(
        label: Text(trigger),
        selected: isSelected,
        selectedColor: AppColors.secondary.withValues(alpha: 0.3),
        backgroundColor: isSuggested ? AppColors.secondary.withValues(alpha: 0.1) : null,
        side: isSuggested && !isSelected
            ? BorderSide(color: AppColors.secondary.withValues(alpha: 0.5))
            : null,
        avatar: isSuggested && !isSelected
            ? Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary.withValues(alpha: 0.7))
            : null,
        onSelected: (selected) {
          HapticFeedback.selectionClick();
          setState(() {
            if (selected) { _selectedTriggers.add(trigger); }
            else { _selectedTriggers.remove(trigger); }
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
    final color = Color.lerp(baseColor, highlightColor, t < 0.5 ? t * 2 : 2 - t * 2)!;
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
    required this.children, this.trailing,
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
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

  const _HandDiagram({required this.selectedFingers, required this.onFingerTap});
  final Set<String> selectedFingers;
  final ValueChanged<String> onFingerTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Левая рука
        Expanded(child: _HandVisual(
          label: S.current.leftHand,
          fingers: const ['Большой Л', 'Указат. Л', 'Средний Л', 'Безымян. Л', 'Мизинец Л'],
          selectedFingers: selectedFingers,
          onFingerTap: onFingerTap,
          isLeft: true,
        )),
        const SizedBox(width: 8),
        // Правая рука
        Expanded(child: _HandVisual(
          label: S.current.rightHand,
          fingers: const ['Большой П', 'Указат. П', 'Средний П', 'Безымян. П', 'Мизинец П'],
          selectedFingers: selectedFingers,
          onFingerTap: onFingerTap,
          isLeft: false,
        )),
      ],
    );
  }
}

/// Геометрия отдельного пальца (нормализованные координаты 0..1)
/// База - точка крепления к ладони, кончик - вершина пальца.
/// Палец сужается от base к tip (анатомически правильно).
class _Finger {
  const _Finger({
    required this.base,
    required this.tip,
    required this.baseWidth,
    required this.tipWidth,
  });
  final Offset base;
  final Offset tip;
  final double baseWidth;
  final double tipWidth;
}

/// Визуальная рука с тыкабельными пальцами.
/// Использует анатомически правильную форму: ладонь + capsule-пальцы.
class _HandVisual extends StatelessWidget {

  const _HandVisual({
    required this.label,
    required this.fingers,
    required this.selectedFingers,
    required this.onFingerTap,
    required this.isLeft,
  });
  final String label;
  final List<String> fingers;
  final Set<String> selectedFingers;
  final ValueChanged<String> onFingerTap;
  final bool isLeft;

  /// Геометрия 5 пальцев для ПРАВОЙ руки (palm-up, thumb слева, fingers вверх).
  /// Индекс: 0=большой, 1=указат., 2=средний, 3=безымян., 4=мизинец.
  /// Левая рука получается зеркалированием по X.
  static const List<_Finger> _rightFingerGeometry = [
    // Большой - короткий, толстый, отходит под углом вниз-влево от thenar
    _Finger(base: Offset(0.24, 0.72), tip: Offset(0.06, 0.54), baseWidth: 0.17, tipWidth: 0.11),
    // Указательный - чуть короче среднего, слегка отклоняется
    _Finger(base: Offset(0.34, 0.48), tip: Offset(0.32, 0.10), baseWidth: 0.13, tipWidth: 0.095),
    // Средний (самый длинный)
    _Finger(base: Offset(0.49, 0.46), tip: Offset(0.50, 0.03), baseWidth: 0.135, tipWidth: 0.10),
    // Безымянный
    _Finger(base: Offset(0.63, 0.47), tip: Offset(0.66, 0.07), baseWidth: 0.125, tipWidth: 0.09),
    // Мизинец - самый короткий, отходит немного вбок
    _Finger(base: Offset(0.76, 0.51), tip: Offset(0.84, 0.20), baseWidth: 0.10, tipWidth: 0.075),
  ];

  /// Вернуть геометрию с учётом стороны (левая = зеркально по X)
  List<_Finger> _geometry() {
    if (!isLeft) return _rightFingerGeometry;
    return _rightFingerGeometry
        .map(
          (f) => _Finger(
            base: Offset(1 - f.base.dx, f.base.dy),
            tip: Offset(1 - f.tip.dx, f.tip.dy),
            baseWidth: f.baseWidth,
            tipWidth: f.tipWidth,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final geom = _geometry();
    final hasSelection = fingers.any(selectedFingers.contains);
    final selected = List.generate(5, (i) => selectedFingers.contains(fingers[i]));

    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 4),
        SizedBox(
          height: 240,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              const h = 240.0;
              return Stack(
                children: [
                  // Анатомическая заливка руки (ладонь + 5 пальцев) с подсветкой выбранных
                  CustomPaint(
                    size: Size(w, h),
                    painter: _HandPainter(
                      geometry: geom,
                      selected: selected,
                      isLeft: isLeft,
                    ),
                  ),
                  // Подсказка по центру ладони (если ничего не выбрано)
                  if (!hasSelection)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: h * 0.75,
                      child: Text(
                        S.current.tapHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ),
                  // Невидимые тап-таргеты над кончиками пальцев (44x44 - минимум по a11y)
                  ...List.generate(5, (i) {
                    final tip = geom[i].tip;
                    final x = tip.dx * w - 22;
                    final y = tip.dy * h - 22;
                    return Positioned(
                      left: x,
                      top: y,
                      width: 44,
                      height: 44,
                      child: Semantics(
                        button: true,
                        label: S.current.a11yFingerButton(fingers[i]),
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
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Анатомический painter руки: ладонь с thenar eminence + 5 сужающихся
/// пальцев. Palm-up ориентация (ладонь к зрителю, пальцы вверх).
class _HandPainter extends CustomPainter {

  _HandPainter({
    required this.geometry,
    required this.selected,
    required this.isLeft,
  });
  final List<_Finger> geometry;
  final List<bool> selected;
  final bool isLeft;

  static const _baseFill = Color(0xFFF5E4D0); // тёплый телесный
  static const _baseFillDark = Color(0xFFE8CCAE); // тень на ладони
  static const _baseStroke = Color(0xFF9E7B5A);
  static const _creaseColor = Color(0x55A0755A); // складки на ладони
  static const _selectedFill = Color(0xFF7EC4F5);
  static const _selectedStroke = Color(0xFF1565C0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Padding по краям чтобы обводка не обрезалась
    final strokeW = (w * 0.012).clamp(1.2, 2.2);

    // ----- 1. ЛАДОНЬ (с thenar eminence на стороне большого пальца) -----
    // Строим для правой руки, зеркалим если isLeft
    final palmPath = _buildPalmPath(w, h);
    if (isLeft) {
      final m = Matrix4.identity()
        ..translateByDouble(w, 0, 0, 1)
        ..scaleByDouble(-1, 1, 1, 1);
      final mirrored = palmPath.transform(m.storage);
      _paintPalm(canvas, mirrored, strokeW);
    } else {
      _paintPalm(canvas, palmPath, strokeW);
    }

    // ----- 2. ПАЛЬЦЫ -----
    // Каждый палец - tapered path с закруглённым кончиком.
    // Рисуем от большого к мизинцу, но большой первым чтобы ладонь его "перекрыла".
    // Порядок: сначала большой палец (под ладонью), потом ладонь уже нарисована,
    // потом остальные 4 пальца поверх. Поскольку ладонь уже отрисована выше,
    // большой палец рисуем теперь - он будет выглядеть "выходящим" из ладони.
    for (var i = 0; i < geometry.length; i++) {
      final f = geometry[i];
      final isSel = selected[i];
      final base = Offset(f.base.dx * w, f.base.dy * h);
      final tip = Offset(f.tip.dx * w, f.tip.dy * h);
      final baseW = f.baseWidth * w;
      final tipW = f.tipWidth * w;

      final path = _buildFingerPath(base, tip, baseW, tipW);

      final fill = Paint()
        ..color = isSel ? _selectedFill : _baseFill
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = isSel ? _selectedStroke : _baseStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeJoin = StrokeJoin.round;

      canvas
        ..drawPath(path, fill)
        ..drawPath(path, stroke);

      // Линии суставов (костяшки) - две тонкие поперечные линии вдоль пальца
      _drawKnuckles(canvas, base, tip, baseW, tipW, strokeW);

      // Ноготь на кончике (маленький полукруг/овал)
      _drawNail(canvas, base, tip, tipW, isSel);
    }
  }

  // --- Построение пути ладони (правая рука, palm-up) ---
  Path _buildPalmPath(double w, double h) {
    // Ориентиры (для правой руки в нормализованных координатах):
    // Большой палец ВЛЕВО, мизинец ВПРАВО, запястье внизу.
    // Ладонь формирует неровный "щит" с бугром thenar слева и лёгким
    // hypothenar справа.
    return Path()
      // Начинаем у основания указательного (верх-лево ладони)
      ..moveTo(w * 0.28, h * 0.48)
      // Дуга вверху под основаниями пальцев (плавная - даёт форму выпуклости)
      ..cubicTo(
        w * 0.40, h * 0.44, // control 1
        w * 0.60, h * 0.44, // control 2
        w * 0.82, h * 0.51, // конец (основание мизинца)
      )
      // Правая сторона ладони (hypothenar) вниз до запястья
      ..cubicTo(
        w * 0.92, h * 0.65,
        w * 0.86, h * 0.90,
        w * 0.72, h * 0.97,
      )
      // Основание (запястье) - лёгкая кривая
      ..cubicTo(
        w * 0.60, h * 1.02,
        w * 0.40, h * 1.02,
        w * 0.28, h * 0.97,
      )
      // Левая сторона с thenar eminence (выпуклость мышцы большого пальца)
      ..cubicTo(
        w * 0.15, h * 0.90,
        w * 0.10, h * 0.78,
        w * 0.16, h * 0.68,
      )
      // Верх thenar, переходит в основание большого пальца
      ..cubicTo(
        w * 0.20, h * 0.58,
        w * 0.22, h * 0.52,
        w * 0.28, h * 0.48,
      )
      ..close();
  }

  void _paintPalm(Canvas canvas, Path path, double strokeW) {
    final fill = Paint()
      ..color = _baseFill
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = _baseStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..drawPath(path, fill)
      ..drawPath(path, stroke);

    // Складки на ладони (линии жизни/сердца) - добавляют реалистичность
    final bounds = path.getBounds();
    final w = bounds.width;
    final h = bounds.height;
    final left = bounds.left;
    final top = bounds.top;

    final creasePaint = Paint()
      ..color = _creaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 0.7
      ..strokeCap = StrokeCap.round;

    // Линия головы (горизонтальная складка через середину ладони)
    final crease1 = Path()
      ..moveTo(left + w * 0.22, top + h * 0.70)
      ..quadraticBezierTo(
        left + w * 0.50, top + h * 0.72,
        left + w * 0.72, top + h * 0.68,
      );
    canvas.drawPath(crease1, creasePaint);

    // Линия жизни (дуга вокруг thenar)
    final crease2 = Path()
      ..moveTo(left + w * 0.28, top + h * 0.55)
      ..quadraticBezierTo(
        left + w * 0.20, top + h * 0.78,
        left + w * 0.32, top + h * 0.94,
      );
    canvas.drawPath(crease2, creasePaint);
  }

  // --- Путь одного сужающегося пальца ---
  Path _buildFingerPath(Offset base, Offset tip, double baseW, double tipW) {
    final dx = tip.dx - base.dx;
    final dy = tip.dy - base.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.1) return Path();

    // Единичный вектор направления
    final ux = dx / len;
    final uy = dy / len;
    // Перпендикуляр (повёрнут на 90°)
    final px = -uy;
    final py = ux;

    final hb = baseW / 2;
    final ht = tipW / 2;

    // Углы прямоугольника-трапеции
    final baseL = Offset(base.dx + px * hb, base.dy + py * hb);
    final baseR = Offset(base.dx - px * hb, base.dy - py * hb);
    final tipL = Offset(tip.dx + px * ht, tip.dy + py * ht);
    final tipR = Offset(tip.dx - px * ht, tip.dy - py * ht);

    // Точка продления за кончик для скругления (полукруг)
    final tipExtend = Offset(tip.dx + ux * ht * 1.1, tip.dy + uy * ht * 1.1);

    // Небольшое уширение в середине (реальный палец не идеальный трапецоид)
    const midT = 0.55;
    final midCenter = Offset(
      base.dx + dx * midT,
      base.dy + dy * midT,
    );
    final midHalf = (hb * 0.85 + ht * 1.15) / 2;
    final midL = Offset(midCenter.dx + px * midHalf, midCenter.dy + py * midHalf);
    final midR = Offset(midCenter.dx - px * midHalf, midCenter.dy - py * midHalf);

    return Path()
      ..moveTo(baseL.dx, baseL.dy)
      // Левая сторона: от базы через среднюю точку к кончику
      ..quadraticBezierTo(midL.dx, midL.dy, tipL.dx, tipL.dy)
      // Скруглённый кончик
      ..quadraticBezierTo(tipExtend.dx, tipExtend.dy, tipR.dx, tipR.dy)
      // Правая сторона: от кончика через среднюю точку к базе
      ..quadraticBezierTo(midR.dx, midR.dy, baseR.dx, baseR.dy)
      ..close();
  }

  // --- Костяшки (2 поперечные складки вдоль пальца) ---
  void _drawKnuckles(
    Canvas canvas,
    Offset base,
    Offset tip,
    double baseW,
    double tipW,
    double strokeW,
  ) {
    final dx = tip.dx - base.dx;
    final dy = tip.dy - base.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.1) return;
    final ux = dx / len;
    final uy = dy / len;
    final px = -uy;
    final py = ux;

    final creasePaint = Paint()
      ..color = _creaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 0.6
      ..strokeCap = StrokeCap.round;

    // Две поперечные складки на 35% и 70% длины пальца
    for (final t in [0.35, 0.70]) {
      final center = Offset(base.dx + dx * t, base.dy + dy * t);
      final halfW = (baseW * (1 - t) + tipW * t) / 2 * 0.75;
      final p1 = Offset(center.dx + px * halfW, center.dy + py * halfW);
      final p2 = Offset(center.dx - px * halfW, center.dy - py * halfW);
      canvas.drawLine(p1, p2, creasePaint);
    }
  }

  // --- Ноготь на кончике (маленький овал) ---
  void _drawNail(
    Canvas canvas,
    Offset base,
    Offset tip,
    double tipW,
    bool isSelected,
  ) {
    final dx = tip.dx - base.dx;
    final dy = tip.dy - base.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.1) return;
    final ux = dx / len;
    final uy = dy / len;

    // Ноготь немного отодвинут от кончика к основанию
    final nailCenter = Offset(
      tip.dx - ux * tipW * 0.55,
      tip.dy - uy * tipW * 0.55,
    );
    final nailPaint = Paint()
      ..color = isSelected
          ? Colors.white.withValues(alpha: 0.85)
          : _baseFillDark.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(nailCenter, tipW * 0.35, nailPaint);
  }

  @override
  bool shouldRepaint(covariant _HandPainter oldDelegate) {
    for (var i = 0; i < selected.length; i++) {
      if (selected[i] != oldDelegate.selected[i]) return true;
    }
    return false;
  }
}
