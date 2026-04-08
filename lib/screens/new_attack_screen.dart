import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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

class _NewAttackScreenState extends State<NewAttackScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadWeather();
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

    await context.read<AttackProvider>().addAttack(event);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Приступ записан'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            const SizedBox(height: 16),

            // Тяжесть с динамическим цветом
            const Text('Тяжесть (RCS)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                      onChanged: (v) => setState(() => _severity = v.round()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Цвет пальцев - градиентные плашки
            const Text('Цвет пальцев', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 16),

            // Триггеры с умной подсветкой по погоде
            Row(
              children: [
                const Text('Что вызвало?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (_suggestedTriggers.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary.withValues(alpha: 0.7)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _buildSortedTriggers(),
            ),
            const SizedBox(height: 16),

            // Поражённые пальцы
            const Text('Поражённые пальцы', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: fingerNames.map((finger) {
                final isSelected = _selectedFingers.contains(finger);
                return FilterChip(
                  label: Text(finger, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: AppColors.phaseBlue.withValues(alpha: 0.3),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) { _selectedFingers.add(finger); }
                      else { _selectedFingers.remove(finger); }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Длительность
            const Text('Длительность (мин)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                    onChanged: (v) => setState(() => _durationMinutes = v.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Фото
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_photoPath == null ? 'Сделать фото' : 'Переснять'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                ),
                if (_photoPath != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green),
                  const Text(' Фото сохранено'),
                ],
              ],
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 24),

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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('Загрузка погоды...'),
            ],
          ),
        ),
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
          setState(() {
            if (selected) { _selectedTriggers.add(trigger); }
            else { _selectedTriggers.remove(trigger); }
          });
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
