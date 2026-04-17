import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vasolog/l10n/app_strings.dart';
import 'package:vasolog/models/attack_event.dart';

/// Генерация PDF-отчёта для врача.
/// Использует Noto Sans из Google Fonts (через printing.PdfGoogleFonts)
/// чтобы поддерживать кириллицу, греческий, латинский и т.п.
/// Для CJK (японский/корейский) printing package использует
/// отдельные варианты Noto (Noto Sans JP/KR).
class PdfReportService {
  /// Создать PDF отчёт за период
  Future<Uint8List> generateReport({
    required List<AttackEvent> attacks,
    required DateTime startDate,
    required DateTime endDate,
    String locale = 'en',
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd.MM.yyyy', locale);
    final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', locale);

    // Загружаем Noto Sans - покрывает латиницу, кириллицу, греческий и т.д.
    // CJK (японский/корейский) пока не поддерживается - там будут квадраты.
    // При неудаче (нет интернета) фоллбэк на стандартный Helvetica.
    pw.Font? regular;
    pw.Font? bold;
    try {
      regular = await PdfGoogleFonts.notoSansRegular();
      bold = await PdfGoogleFonts.notoSansBold();
    } catch (e) {
      debugPrint('PDF font load failed, using default: $e');
    }

    // Статистика
    final avgSeverity = attacks.isEmpty
        ? 0.0
        : attacks.map((a) => a.severity).reduce((a, b) => a + b) /
              attacks.length;

    // Подсчёт триггеров
    final triggerCount = <String, int>{};
    for (final attack in attacks) {
      for (final trigger in attack.triggers) {
        triggerCount[trigger] = (triggerCount[trigger] ?? 0) + 1;
      }
    }
    final sortedTriggers = triggerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final theme = pw.ThemeData.withFont(base: regular, bold: bold);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: theme,
        build: (context) => [
          // Заголовок
          pw.Header(
            level: 0,
            child: pw.Text(
              S.current.pdfTitle,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${S.current.pdfPeriod}: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            '${S.current.pdfGenerated}: ${dateTimeFormat.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          // Сводка
          pw.Header(text: S.current.pdfSummary),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            data: [
              [S.current.pdfMetric, S.current.pdfValue],
              [S.current.pdfTotalAttacks, '${attacks.length}'],
              [S.current.pdfAvgSeverity, avgSeverity.toStringAsFixed(1)],
              [
                S.current.pdfMostCommonTrigger,
                if (sortedTriggers.isNotEmpty)
                  S.current.triggerFromKey(sortedTriggers.first.key)
                else
                  S.current.notAvailable,
              ],
              [S.current.pdfAvgTemp, _avgTemp(attacks)],
            ],
          ),
          pw.SizedBox(height: 20),

          // Таблица триггеров
          if (sortedTriggers.isNotEmpty) ...[
            pw.Header(text: S.current.pdfTriggerAnalysis),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              data: [
                [
                  S.current.pdfColTrigger,
                  S.current.pdfColCount,
                  S.current.pdfColPct,
                ],
                ...sortedTriggers.map(
                  (e) => [
                    S.current.triggerFromKey(e.key),
                    '${e.value}',
                    '${(e.value / attacks.length * 100).toStringAsFixed(0)}%',
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Детальный лог приступов
          pw.Header(text: S.current.pdfAttackLog),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(),
              4: const pw.FlexColumnWidth(2),
            },
            data: [
              [
                S.current.pdfColDateTime,
                S.current.pdfColRcs,
                S.current.pdfColPhase,
                S.current.pdfColTemp,
                S.current.pdfColTriggers,
              ],
              ...attacks.map(
                (a) => [
                  dateTimeFormat.format(a.timestamp),
                  '${a.severity}/10',
                  S.current.phaseFromKey(a.colorPhase),
                  a.temperature?.toStringAsFixed(1) ?? '-',
                  a.triggers.map(S.current.triggerFromKey).join(', '),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            S.current.pdfFooter,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  String _avgTemp(List<AttackEvent> attacks) {
    final temps = attacks
        .where((a) => a.temperature != null)
        .map((a) => a.temperature!);
    if (temps.isEmpty) return S.current.notAvailable;
    final avg = temps.reduce((a, b) => a + b) / temps.length;
    return '${avg.toStringAsFixed(1)}°C';
  }
}
