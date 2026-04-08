import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/attack_provider.dart';
import '../utils/constants.dart';

/// Экран истории приступов с графиком
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('История'),
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
      body: Consumer<AttackProvider>(
        builder: (context, provider, _) {
          final attacks = provider.attacks;

          if (attacks.isEmpty) {
            return const Center(
              child: Text(
                'Приступов пока нет.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Данные для графика за 7 дней
          final weekData = _buildWeekData(provider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // График за неделю
                const Text(
                  'Приступы за неделю',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 10,
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final days = [
                                    'Пн', 'Вт', 'Ср', 'Чт',
                                    'Пт', 'Сб', 'Вс'
                                  ];
                                  final index = value.toInt();
                                  if (index >= 0 && index < days.length) {
                                    return Text(
                                      days[index],
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: weekData,
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Статистика
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статистика',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _StatRow(
                          'Средн. тяжесть за неделю',
                          provider.weeklyAverageSeverity.toStringAsFixed(1),
                        ),
                        _StatRow(
                          'Средн. тяжесть за месяц',
                          provider.monthlyAverageSeverity.toStringAsFixed(1),
                        ),
                        _StatRow(
                          'Всего приступов',
                          '${provider.totalCount}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Полный список
                const Text(
                  'Все приступы',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...attacks.map((attack) {
                  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: severityColor(attack.severity),
                        foregroundColor: Colors.white,
                        child: Text('${attack.severity}'),
                      ),
                      title: Text(dateFormat.format(attack.timestamp)),
                      subtitle: Text(attack.colorPhaseLabel),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (attack.triggers.isNotEmpty)
                                Text('Триггеры: ${attack.triggers.join(", ")}'),
                              if (attack.affectedFingers.isNotEmpty)
                                Text('Пальцы: ${attack.affectedFingers.join(", ")}'),
                              if (attack.durationMinutes > 0)
                                Text('Длительность: ${attack.durationMinutes} мин'),
                              if (attack.temperature != null)
                                Text(
                                    'Погода: ${attack.temperature!.toStringAsFixed(1)}°C, '
                                    'влажн. ${attack.humidity?.toStringAsFixed(0)}%'),
                              if (attack.notes != null)
                                Text('Заметки: ${attack.notes}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Данные графика: средняя тяжесть по дням недели
  List<BarChartGroupData> _buildWeekData(AttackProvider provider) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final result = <BarChartGroupData>[];

    for (int i = 0; i < 7; i++) {
      final day = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final dayEnd = day.add(const Duration(days: 1));
      final dayAttacks = provider.getAttacksByRange(day, dayEnd);

      double avgSeverity = 0;
      if (dayAttacks.isNotEmpty) {
        avgSeverity = dayAttacks
                .map((a) => a.severity)
                .reduce((a, b) => a + b)
                .toDouble() /
            dayAttacks.length;
      }

      result.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: avgSeverity,
              color: severityColor(avgSeverity.round()),
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    return result;
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
