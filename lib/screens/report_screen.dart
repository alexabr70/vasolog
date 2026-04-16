import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/providers/attack_provider.dart';
import 'package:vasolog/services/pdf_report_service.dart';
import 'package:vasolog/utils/constants.dart';

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
        SnackBar(
          content: Text(S.current.noAttacksInPeriod),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final pdfBytes = await _pdfService.generateReport(
      attacks: attacks,
      startDate: _startDate,
      endDate: _endDate,
      locale: S.current.locale,
    );

    // Поделиться PDF через системный share sheet
    final fileName =
        'VasoLog_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', S.current.locale);
    final provider = context.watch<AttackProvider>();
    final attacksInRange = provider.getAttacksByRange(_startDate, _endDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.reportTitle),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.createPdfReport,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.current.reportDescription,
                      style: const TextStyle(color: Colors.grey),
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
                    Text(
                      S.current.period,
                      style: const TextStyle(
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
                      S.current.attacksInPeriod(attacksInRange.length),
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
                _periodChip(S.current.periodDays(7), 7),
                const SizedBox(width: 8),
                _periodChip(S.current.periodDays(30), 30),
                const SizedBox(width: 8),
                _periodChip(S.current.periodDays(90), 90),
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
                label: Text(
                  S.current.createAndSharePdf,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
