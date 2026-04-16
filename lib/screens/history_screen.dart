import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/providers/attack_provider.dart';
import 'package:vasolog/utils/constants.dart';

/// Экран истории приступов с графиком
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.tabHistory),
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
            return Center(
              child: Text(
                S.current.noAttacksYet,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Данные для графика за 7 дней
          final weekData = _buildWeekData(provider);
          // Локализованные аббревиатуры дней (0=Пн..6=Вс)
          final weekDayLabels = S.current.weekdayAbbrs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // График за неделю
                Text(
                  S.current.attacksThisWeek,
                  style: const TextStyle(
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
                                  final index = value.toInt();
                                  if (index >= 0 && index < weekDayLabels.length) {
                                    return Text(
                                      weekDayLabels[index],
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles(),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: weekData,
                          gridData: const FlGridData(show: false),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                    if (rod.toY == 0) return null;
                                    return BarTooltipItem(
                                      'RCS: ${rod.toY.toStringAsFixed(1)}',
                                      TextStyle(
                                        color: severityColor(rod.toY.round()),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                            ),
                          ),
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
                        Text(
                          S.current.statistics,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _StatRow(
                          S.current.avgWeekSeverity,
                          provider.weeklyAverageSeverity.toStringAsFixed(1),
                        ),
                        _StatRow(
                          S.current.avgMonthSeverity,
                          provider.monthlyAverageSeverity.toStringAsFixed(1),
                        ),
                        _StatRow(
                          S.current.totalAttacks,
                          '${provider.totalCount}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Полный список
                Text(
                  S.current.allAttacks,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...attacks.map((attack) {
                  final dateFormat = DateFormat('dd MMM yyyy, HH:mm', S.current.locale);
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
                                Text('${S.current.labelTriggers}: ${attack.triggers.join(", ")}'),
                              if (attack.affectedFingers.isNotEmpty)
                                Text(
                                  '${S.current.labelFingers}: ${attack.affectedFingers.join(", ")}',
                                ),
                              if (attack.durationMinutes > 0)
                                Text(
                                  '${S.current.labelDuration}: ${attack.durationMinutes} ${S.current.minutesAbbr}',
                                ),
                              if (attack.temperature != null)
                                Text(
                                  '${S.current.labelWeather}: ${attack.temperature!.toStringAsFixed(1)}°C, '
                                  '${S.current.labelHumidity} ${attack.humidity?.toStringAsFixed(0)}%',
                                ),
                              if (attack.notes != null)
                                Text('${S.current.notes}: ${attack.notes}'),
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

    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayEnd = day.add(const Duration(days: 1));
      final dayAttacks = provider.getAttacksByRange(day, dayEnd);

      double avgSeverity = 0;
      if (dayAttacks.isNotEmpty) {
        avgSeverity =
            dayAttacks
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
  const _StatRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
