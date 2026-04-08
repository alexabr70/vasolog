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

/// Экран записи нового приступа
class NewAttackScreen extends StatefulWidget {
  const NewAttackScreen({super.key});

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
    _applySmartDefaults();
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
        const SnackBar(
          content: Text('Включите геолокацию для автозаполнения погоды'),
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

    final event = AttackEvent(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
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
      final provider = context.read<AttackProvider>();
      await provider.addAttack(event);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Приступ записан'),
            backgroundColor: Colors.green,
          ),
        );
        // In-app review после 5-го приступа, макс 1 раз
        _maybeRequestReview(provider.totalCount);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
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
        title: const Text('Записать приступ'),
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
                  label: const Text('Как прошлый раз'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                ),
              ),

            // === СЕКЦИЯ 1: Оценка приступа ===
            _SectionCard(
              title: 'Оценка приступа',
              icon: Icons.speed_rounded,
              children: [
                // Тяжесть
                const Text('Тяжесть (RCS)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                  ],
                ),
                const SizedBox(height: 12),

                // Цвет пальцев
                const Text('Цвет пальцев', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                const Text('Длительность', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('$_durationMinutes', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text(' мин', style: TextStyle(fontSize: 16)),
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
              title: 'Что вызвало?',
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
              title: 'Поражённые пальцы',
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
              title: 'Дополнительно',
              icon: Icons.note_add_rounded,
              children: [
                // Фото
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(_photoPath == null ? 'Сделать фото' : 'Переснять'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_photoPath != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const Text(' Фото', style: TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Заметки
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Заметки (необязательно)',
                    hintText: 'Дополнительные детали...',
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
                    : const Text('Сохранить', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      final cacheLabel = w.isCached ? ' (${w.minutesAgo} мин назад)' : '';
      return Card(
        color: w.isCached ? Colors.orange[50] : Colors.blue[50],
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
                  'Влажн. ${w.humidity.toStringAsFixed(0)}% · Ветер ${w.windSpeed.toStringAsFixed(1)} м/с$cacheLabel',
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
      'white' => 'Белый',
      'blue' => 'Синий',
      'red' => 'Красный',
      _ => 'Смешан.',
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

/// Интерактивная схема рук для выбора пальцев
class _HandDiagram extends StatelessWidget {
  final Set<String> selectedFingers;
  final ValueChanged<String> onFingerTap;

  const _HandDiagram({required this.selectedFingers, required this.onFingerTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Левая рука
        Expanded(
          child: Column(
            children: [
              Text('Левая', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 8),
              _buildHandGrid([
                'Большой Л', 'Указат. Л', 'Средний Л', 'Безымян. Л', 'Мизинец Л',
              ]),
            ],
          ),
        ),
        Container(width: 1, height: 100, color: Colors.grey[300]),
        // Правая рука
        Expanded(
          child: Column(
            children: [
              Text('Правая', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 8),
              _buildHandGrid([
                'Большой П', 'Указат. П', 'Средний П', 'Безымян. П', 'Мизинец П',
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHandGrid(List<String> fingers) {
    // Расположение пальцев в виде дуги (как настоящая рука)
    final shortNames = {
      'Большой Л': '1', 'Указат. Л': '2', 'Средний Л': '3',
      'Безымян. Л': '4', 'Мизинец Л': '5',
      'Большой П': '1', 'Указат. П': '2', 'Средний П': '3',
      'Безымян. П': '4', 'Мизинец П': '5',
    };
    final fullNames = {
      'Большой Л': 'Большой', 'Указат. Л': 'Указат.', 'Средний Л': 'Средний',
      'Безымян. Л': 'Безым.', 'Мизинец Л': 'Мизинец',
      'Большой П': 'Большой', 'Указат. П': 'Указат.', 'Средний П': 'Средний',
      'Безымян. П': 'Безым.', 'Мизинец П': 'Мизинец',
    };

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: fingers.map((finger) {
        final isSelected = selectedFingers.contains(finger);
        return GestureDetector(
          onTap: () => onFingerTap(finger),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.phaseBlue.withValues(alpha: 0.25)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.phaseBlue : Colors.grey.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  shortNames[finger] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.phaseBlue : Colors.grey[600],
                  ),
                ),
                Text(
                  fullNames[finger] ?? '',
                  style: TextStyle(fontSize: 8, color: isSelected ? AppColors.phaseBlue : Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
