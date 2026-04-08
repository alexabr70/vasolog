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

  double? _temperature;
  double? _humidity;
  double? _pressure;
  double? _windSpeed;
  String? _weatherDesc;
  double? _latitude;
  double? _longitude;

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
          _temperature = data.temperature;
          _humidity = data.humidity;
          _pressure = data.pressure;
          _windSpeed = data.windSpeed;
          _weatherDesc = data.description;
        });
      }
    }
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
      temperature: _temperature,
      humidity: _humidity,
      pressure: _pressure,
      windSpeed: _windSpeed,
      weatherDescription: _weatherDesc,
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
            if (_temperature != null)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.thermostat, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '${_temperature!.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Text('Влажн. ${_humidity?.toStringAsFixed(0)}%'),
                      const SizedBox(width: 16),
                      Text('Ветер ${_windSpeed?.toStringAsFixed(1)} м/с'),
                    ],
                  ),
                ),
              )
            else
              const Card(
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
              ),
            const SizedBox(height: 16),

            // Тяжесть
            const Text('Тяжесть (RCS)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('$_severity', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: severityColor(_severity))),
                const Text('/10', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _severity.toDouble(),
                    min: 0, max: 10, divisions: 10,
                    activeColor: severityColor(_severity),
                    label: '$_severity',
                    onChanged: (v) => setState(() => _severity = v.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Цвет пальцев
            const Text('Цвет пальцев', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: colorPhases.entries.map((e) {
                final isSelected = _colorPhase == e.key;
                Color chipColor;
                switch (e.key) {
                  case 'white': chipColor = AppColors.phaseWhite; break;
                  case 'blue': chipColor = AppColors.phaseBlue; break;
                  case 'red': chipColor = AppColors.phaseRed; break;
                  default: chipColor = Colors.grey;
                }
                return ChoiceChip(
                  label: Text(e.value),
                  selected: isSelected,
                  selectedColor: chipColor,
                  onSelected: (_) => setState(() => _colorPhase = e.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Триггеры
            const Text('Что вызвало?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: availableTriggers.map((trigger) {
                final isSelected = _selectedTriggers.contains(trigger);
                return FilterChip(
                  label: Text(trigger),
                  selected: isSelected,
                  selectedColor: AppColors.secondary.withValues(alpha: 0.3),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) { _selectedTriggers.add(trigger); }
                      else { _selectedTriggers.remove(trigger); }
                    });
                  },
                );
              }).toList(),
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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
