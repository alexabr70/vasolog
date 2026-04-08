import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attack_provider.dart';
import '../utils/constants.dart';

/// Главный экран - дашборд (встраивается в MainShell)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                // Статкарточка с анимацией появления
                _AnimatedEntry(
                  delay: 0,
                  child: _StatCard(
                    totalAttacks: provider.totalCount,
                    weeklyAttacks: recentAttacks.length,
                    avgSeverity: provider.weeklyAverageSeverity,
                  ),
                ),
                const SizedBox(height: 16),

                // Streak - дней без приступа
                if (provider.totalCount > 0)
                  _AnimatedEntry(
                    delay: 80,
                    child: _StreakCard(days: provider.daysSinceLastAttack),
                  ),
                const SizedBox(height: 16),

                _AnimatedEntry(
                  delay: 100,
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
          HapticFeedback.heavyImpact();
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
