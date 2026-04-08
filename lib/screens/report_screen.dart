import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/attack_provider.dart';
import '../services/pdf_report_service.dart';
import '../utils/constants.dart';

/// Экран генерации PDF-отчёта для врача
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final _pdfService = PdfReportService();

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _generateAndShare() async {
    final provider = context.read<AttackProvider>();
    final attacks = provider.getAttacksByRange(_startDate, _endDate);

    if (attacks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет приступов за выбранный период'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final pdfBytes = await _pdfService.generateReport(
      attacks: attacks,
      startDate: _startDate,
      endDate: _endDate,
    );

    // Показать превью и дать поделиться/распечатать
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'VasoLog_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final provider = context.watch<AttackProvider>();
    final attacksInRange = provider.getAttacksByRange(_startDate, _endDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Отчёт для врача'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Описание
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Создать PDF отчёт',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Создай подробный отчёт о приступах Рейно '
                      'для лечащего врача. Включает журнал приступов, '
                      'анализ триггеров и корреляцию с погодой.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Выбор периода
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Период',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${dateFormat.format(_startDate)} - '
                              '${dateFormat.format(_endDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.edit, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${attacksInRange.length} приступов за этот период',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Быстрые кнопки периодов
            Row(
              children: [
                _periodChip('7 дней', 7),
                const SizedBox(width: 8),
                _periodChip('30 дней', 30),
                const SizedBox(width: 8),
                _periodChip('90 дней', 90),
              ],
            ),

            const Spacer(),

            // Кнопка генерации
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generateAndShare,
                icon: const Icon(Icons.picture_as_pdf, size: 24),
                label: const Text(
                  'Создать и отправить PDF',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label, int days) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _startDate = DateTime.now().subtract(Duration(days: days));
          _endDate = DateTime.now();
        });
      },
    );
  }
}
