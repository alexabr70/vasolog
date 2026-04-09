import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attack_provider.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import 'new_attack_screen.dart';

/// Главный экран - дашборд (встраивается в MainShell)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData? _weather;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final pos = await LocationService().getCurrentPosition();
    if (pos != null) {
      final data = await WeatherService().getCurrentWeather(pos.latitude, pos.longitude);
      if (mounted) setState(() => _weather = data);
    } else {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VasoLog', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
        elevation: 0,
      ),
      body: Consumer<AttackProvider>(
        builder: (context, provider, _) {
          final recentAttacks = provider.recentAttacks(7);
          final triggers = provider.monthlyTriggers;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Погода с предупреждением
                if (_weather != null)
                  _AnimatedEntry(
                    delay: 0,
                    child: _WeatherAlert(weather: _weather!),
                  ),
                if (_weather != null) const SizedBox(height: 12),

                // Статкарточка с анимацией появления
                _AnimatedEntry(
                  delay: _weather != null ? 80 : 0,
                  child: _StatCard(
                    totalAttacks: provider.totalCount,
                    weeklyAttacks: recentAttacks.length,
                    avgSeverity: provider.weeklyAverageSeverity,
                  ),
                ),
                const SizedBox(height: 16),

                // Streak - дней без приступа
                if (provider.daysSinceLastAttack >= 0)
                  _AnimatedEntry(
                    delay: 80,
                    child: _StreakCard(days: provider.daysSinceLastAttack),
                  ),
                const SizedBox(height: 16),

                // Мини-график тренда за 7 дней
                if (recentAttacks.isNotEmpty)
                  _AnimatedEntry(
                    delay: 100,
                    child: _WeekTrendChart(provider: provider),
                  ),
                if (recentAttacks.isNotEmpty) const SizedBox(height: 16),

                _AnimatedEntry(
                  delay: 120,
                  child: const Text(
                    'Последние приступы',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                if (recentAttacks.isEmpty)
                  _AnimatedEntry(
                    delay: 200,
                    child: _EmptyState(),
                  )
                else
                  ...recentAttacks.take(5).indexed.map((item) {
                    final (i, attack) = item;
                    return _AnimatedEntry(
                      delay: 200 + i * 80,
                      child: _AttackTile(
                        attack: attack,
                        onDelete: () {
                          HapticFeedback.mediumImpact();
                          provider.deleteAttack(attack.id);
                          // Undo через SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Приступ удалён'),
                              action: SnackBarAction(
                                label: 'Отменить',
                                onPressed: () => provider.addAttack(attack),
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => NewAttackScreen(editAttack: attack),
                          ));
                        },
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                if (triggers.isNotEmpty) ...[
                  _AnimatedEntry(
                    delay: 600,
                    child: const Text(
                      'Частые триггеры (30 дней)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AnimatedEntry(
                    delay: 700,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: triggers.entries.take(5).map((e) {
                            final maxCount = triggers.values.first;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  SizedBox(width: 110, child: Text(e.key, style: const TextStyle(fontSize: 14))),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: e.value / maxCount),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) => ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: Colors.grey[200],
                                          color: AppColors.primary,
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '${e.value}',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Анимация появления элементов снизу с задержкой
class _AnimatedEntry extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntry({required this.child, required this.delay});

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Мини-график тренда тяжести за 7 дней
class _WeekTrendChart extends StatelessWidget {
  final AttackProvider provider;
  const _WeekTrendChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    final days = <String>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final dayAttacks = provider.getAttacksByRange(dayStart, dayEnd);

      double avg = 0;
      if (dayAttacks.isNotEmpty) {
        avg = dayAttacks.map((a) => a.severity).reduce((a, b) => a + b) / dayAttacks.length;
      }
      spots.add(FlSpot((6 - i).toDouble(), avg));
      days.add(DateFormat('E', 'ru').format(day).substring(0, 2));
    }

    // Если все нули - не показывать
    if (spots.every((s) => s.y == 0)) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Тренд за неделю', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 10,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < days.length) {
                            return Text(days[idx], style: TextStyle(fontSize: 10, color: Colors.grey[500]));
                          }
                          return const Text('');
                        },
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: spot.y > 0 ? 3 : 0,
                          color: severityColor(spot.y.round()),
                          strokeWidth: 0,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) {
                        if (spot.y == 0) return null;
                        return LineTooltipItem(
                          'RCS: ${spot.y.toStringAsFixed(1)}',
                          TextStyle(color: severityColor(spot.y.round()), fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка погоды с предупреждением о холоде
class _WeatherAlert extends StatelessWidget {
  final WeatherData weather;
  const _WeatherAlert({required this.weather});

  @override
  Widget build(BuildContext context) {
    final temp = weather.temperature;
    final isCold = temp <= 10;
    final isVeryCold = temp <= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isVeryCold
          ? (isDark ? Colors.red[900]?.withValues(alpha: 0.3) : Colors.red[50])
          : isCold
              ? (isDark ? Colors.orange[900]?.withValues(alpha: 0.3) : Colors.orange[50])
              : (isDark ? Colors.blue[900]?.withValues(alpha: 0.3) : Colors.blue[50]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isVeryCold ? Icons.ac_unit : isCold ? Icons.cloud : Icons.wb_sunny_rounded,
              color: isVeryCold ? Colors.red : isCold ? Colors.orange : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${temp.toStringAsFixed(0)}°C',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ветер ${weather.windSpeed.toStringAsFixed(0)} м/с · Влажн. ${weather.humidity.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (isCold)
                    Text(
                      isVeryCold
                          ? 'Мороз! Высокий риск приступа. Утепляйте руки.'
                          : 'Прохладно. Берегите руки от холода.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isVeryCold ? Colors.red[700] : Colors.orange[800],
                      ),
                    ),
                ],
              ),
            ),
            if (weather.isCached)
              Tooltip(
                message: '${weather.minutesAgo} мин назад',
                child: Icon(Icons.cached, size: 16, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }
}

/// Красивое пустое состояние
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Center(
          child: Column(
            children: [
              // Градиентная иконка
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.gradientEnd.withValues(alpha: 0.15),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.ac_unit_rounded,
                  size: 40,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Пока нет записей',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Нажми + чтобы записать\nпервый приступ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int totalAttacks;
  final int weeklyAttacks;
  final double avgSeverity;

  const _StatCard({
    required this.totalAttacks,
    required this.weeklyAttacks,
    required this.avgSeverity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(label: 'Всего', value: '$totalAttacks', icon: Icons.summarize_rounded),
            _StatItem(label: 'За неделю', value: '$weeklyAttacks', icon: Icons.calendar_today_rounded),
            _StatItem(
              label: 'Средн. RCS',
              value: avgSeverity.toStringAsFixed(1),
              icon: Icons.speed_rounded,
              valueColor: Colors.amber[300],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatItem({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: double.tryParse(value) ?? 0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) => Text(
            value.contains('.') ? val.toStringAsFixed(1) : value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
            ),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int days;
  const _StreakCard({required this.days});

  @override
  Widget build(BuildContext context) {
    final isMilestone = days >= 7 && days % 7 == 0;
    final emoji = days == 0 ? '💪' : days < 3 ? '🌱' : days < 7 ? '✨' : '🔥';
    final message = days == 0
        ? 'Держись, ты справишься!'
        : days < 3
            ? 'Хорошее начало!'
            : days < 7
                ? 'Отличная серия!'
                : 'Потрясающий результат!';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: days),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) => Text(
                          '$val',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: days >= 7 ? AppColors.severityLow : AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        ' ${_daysLabel(days)} без приступа',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  Text(
                    message,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isMilestone)
              Icon(Icons.emoji_events_rounded, color: Colors.amber[600], size: 28),
          ],
        ),
      ),
    );
  }

  String _daysLabel(int d) {
    if (d % 10 == 1 && d % 100 != 11) return 'день';
    if (d % 10 >= 2 && d % 10 <= 4 && (d % 100 < 10 || d % 100 >= 20)) return 'дня';
    return 'дней';
  }
}

class _AttackTile extends StatelessWidget {
  final dynamic attack;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const _AttackTile({required this.attack, required this.onDelete, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: severityColor(attack.severity),
          foregroundColor: Colors.white,
          child: Text('${attack.severity}'),
        ),
        title: Text(dateFormat.format(attack.timestamp), style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          '${attack.colorPhaseLabel} • ${attack.triggers.join(", ")}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: attack.temperature != null
            ? Text('${attack.temperature!.toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 14, color: Colors.grey))
            : null,
        onTap: onEdit,
        onLongPress: () {
          HapticFeedback.heavyImpact();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Удалить приступ?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                TextButton(
                  onPressed: () { Navigator.pop(context); onDelete(); },
                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
