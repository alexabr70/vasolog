import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/attack_event.dart';
import '../providers/attack_provider.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../l10n/app_strings.dart';

/// Экран записи / редактирования приступа
class NewAttackScreen extends StatefulWidget {
  final AttackEvent? editAttack;
  const NewAttackScreen({super.key, this.editAttack});

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
          duration: Duration(seconds: 3),
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
                            value: _severity.toDouble(),
                            min: 0, max: 10, divisions: 10,
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
                        value: _durationMinutes.toDouble(),
                        min: 0, max: 120, divisions: 24,
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
                '${w.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${S.current.humidity(w.humidity.toStringAsFixed(0))} · ${S.current.windMs(w.windSpeed.toStringAsFixed(1))}$cacheLabel',
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
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.trailing,
    required this.children,
  });

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
  final Set<String> selectedFingers;
  final ValueChanged<String> onFingerTap;

  const _HandDiagram({required this.selectedFingers, required this.onFingerTap});

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

/// Визуальная рука с тыкабельными пальцами (CustomPainter)
class _HandVisual extends StatelessWidget {
  final String label;
  final List<String> fingers;
  final Set<String> selectedFingers;
  final ValueChanged<String> onFingerTap;
  final bool isLeft;

  const _HandVisual({
    required this.label,
    required this.fingers,
    required this.selectedFingers,
    required this.onFingerTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    // Позиции пальцев на холсте (нормализованные 0-1)
    // Расположение как на реальной руке, вид сверху ладонью вниз
    final positions = isLeft
        ? [
            const Offset(0.12, 0.72), // Большой - внизу сбоку
            const Offset(0.22, 0.18), // Указательный
            const Offset(0.42, 0.08), // Средний - самый длинный
            const Offset(0.62, 0.16), // Безымянный
            const Offset(0.80, 0.30), // Мизинец
          ]
        : [
            const Offset(0.88, 0.72), // Большой - зеркально
            const Offset(0.78, 0.18),
            const Offset(0.58, 0.08),
            const Offset(0.38, 0.16),
            const Offset(0.20, 0.30),
          ];

    final shortLabels = ['Б', 'У', 'С', 'Б', 'М'];

    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 4),
        SizedBox(
          height: 180,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = 180.0;
              return Stack(
                children: [
                  // Контур ладони
                  CustomPaint(
                    size: Size(w, h),
                    painter: _HandOutlinePainter(
                      isLeft: isLeft,
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  // Тыкабельные пальцы
                  ...List.generate(5, (i) {
                    final isSelected = selectedFingers.contains(fingers[i]);
                    final pos = positions[i];
                    final x = pos.dx * w - 22;
                    final y = pos.dy * h - 22;
                    return Positioned(
                      left: x,
                      top: y,
                      child: Semantics(
                        button: true,
                        label: S.current.a11yFingerButton(fingers[i]),
                        selected: isSelected,
                        child: GestureDetector(
                          onTap: () => onFingerTap(fingers[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.phaseBlue.withValues(alpha: 0.3)
                                  : Colors.grey.withValues(alpha: 0.08),
                              border: Border.all(
                                color: isSelected ? AppColors.phaseBlue : Colors.grey.withValues(alpha: 0.4),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.phaseBlue.withValues(alpha: 0.3), blurRadius: 8)]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                shortLabels[i],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.phaseBlue : Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
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

/// Контур руки (CustomPainter)
class _HandOutlinePainter extends CustomPainter {
  final bool isLeft;
  final Color color;

  _HandOutlinePainter({required this.isLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Рисуем упрощённый силуэт руки
    final path = Path();
    if (isLeft) {
      // Ладонь
      path.moveTo(w * 0.20, h * 0.95);
      path.quadraticBezierTo(w * 0.05, h * 0.75, w * 0.10, h * 0.60);
      // Большой палец
      path.quadraticBezierTo(w * 0.05, h * 0.55, w * 0.08, h * 0.50);
      // К указательному
      path.quadraticBezierTo(w * 0.12, h * 0.40, w * 0.15, h * 0.28);
      path.quadraticBezierTo(w * 0.18, h * 0.15, w * 0.22, h * 0.10);
      // Средний
      path.quadraticBezierTo(w * 0.30, h * 0.02, w * 0.42, h * 0.02);
      // Безымянный
      path.quadraticBezierTo(w * 0.52, h * 0.04, w * 0.62, h * 0.08);
      // Мизинец
      path.quadraticBezierTo(w * 0.75, h * 0.15, w * 0.85, h * 0.22);
      // Край ладони
      path.quadraticBezierTo(w * 0.95, h * 0.40, w * 0.90, h * 0.65);
      path.quadraticBezierTo(w * 0.85, h * 0.85, w * 0.70, h * 0.95);
      path.close();
    } else {
      // Зеркально
      path.moveTo(w * 0.80, h * 0.95);
      path.quadraticBezierTo(w * 0.95, h * 0.75, w * 0.90, h * 0.60);
      path.quadraticBezierTo(w * 0.95, h * 0.55, w * 0.92, h * 0.50);
      path.quadraticBezierTo(w * 0.88, h * 0.40, w * 0.85, h * 0.28);
      path.quadraticBezierTo(w * 0.82, h * 0.15, w * 0.78, h * 0.10);
      path.quadraticBezierTo(w * 0.70, h * 0.02, w * 0.58, h * 0.02);
      path.quadraticBezierTo(w * 0.48, h * 0.04, w * 0.38, h * 0.08);
      path.quadraticBezierTo(w * 0.25, h * 0.15, w * 0.15, h * 0.22);
      path.quadraticBezierTo(w * 0.05, h * 0.40, w * 0.10, h * 0.65);
      path.quadraticBezierTo(w * 0.15, h * 0.85, w * 0.30, h * 0.95);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
