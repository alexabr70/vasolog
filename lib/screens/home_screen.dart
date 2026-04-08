import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attack_provider.dart';
import '../utils/constants.dart';
import 'new_attack_screen.dart';
import 'history_screen.dart';
import 'report_screen.dart';

/// Главный экран - дашборд
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('VasoLog'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<AttackProvider>(
        builder: (context, provider, _) {
          final recentAttacks = provider.recentAttacks(7);
          final triggers = provider.monthlyTriggers;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatCard(
                  totalAttacks: provider.totalCount,
                  weeklyAttacks: recentAttacks.length,
                  avgSeverity: provider.weeklyAverageSeverity,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Последние приступы',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (recentAttacks.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Приступов пока нет.\nНажми + чтобы записать первый.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                else
                  ...recentAttacks.take(5).map((attack) => _AttackTile(
                        attack: attack,
                        onDelete: () => provider.deleteAttack(attack.id),
                      )),

                const SizedBox(height: 16),

                if (triggers.isNotEmpty) ...[
                  const Text(
                    'Частые триггеры (30 дней)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: triggers.entries.take(5).map((e) {
                          final maxCount = triggers.values.first;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(width: 120, child: Text(e.key)),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: e.value / maxCount,
                                    backgroundColor: Colors.grey[200],
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${e.value}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewAttackScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Записать приступ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(label: 'Всего', value: '$totalAttacks', icon: Icons.summarize),
            _StatItem(label: 'За неделю', value: '$weeklyAttacks', icon: Icons.calendar_today),
            _StatItem(
              label: 'Средн. RCS',
              value: avgSeverity.toStringAsFixed(1),
              icon: Icons.speed,
              color: severityColor(avgSeverity.round()),
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
  final Color? color;

  const _StatItem({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.primary, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _AttackTile extends StatelessWidget {
  final dynamic attack;
  final VoidCallback onDelete;

  const _AttackTile({required this.attack, required this.onDelete});

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
        onLongPress: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Удалить приступ?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                TextButton(
                  onPressed: () { onDelete(); Navigator.pop(context); },
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
