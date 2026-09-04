import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report.dart';
import '../models/student.dart';

class PdfGeneratorService {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF6B4EFF);
  static const PdfColor primaryDark = PdfColor.fromInt(0xFF4728D1);
  static const PdfColor primaryLight = PdfColor.fromInt(0xFFECE7FE);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF00C9A7);
  static const PdfColor accentColor = PdfColor.fromInt(0xFFFFB547);
  static const PdfColor textDark = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF64748B);
  static const PdfColor cardBg = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor borderLight = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor successColor = PdfColor.fromInt(0xFF10B981);
  static const PdfColor dangerColor = PdfColor.fromInt(0xFFEF4444);

  /// Aylık Öğrenci Gelişim ve İlerleme Raporu (A4 Dikey)
  static Future<Uint8List> generateProgressReportPdf(
    StudentReport report, {
    Student? student,
  }) async {
    final doc = pw.Document();

    // Türkçe karakterleri sorunsuz render etmek için Roboto fontları
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontMedium = await PdfGoogleFonts.robotoMedium();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final dateFormat = DateFormat('dd.MM.yyyy');
    final formattedDate = dateFormat.format(report.reportDate);
    final reportCode =
        report.certificateId ?? 'DHB-${report.id.substring(0, report.id.length.clamp(0, 8)).toUpperCase()}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              _buildReportHeader(report, reportCode, fontBold, fontMedium),
              pw.SizedBox(height: 16),

              // ── Öğrenci ve Öğretmen Bilgi Kartı ──
              _buildStudentInfoCard(report, student, formattedDate, fontBold, fontMedium),
              pw.SizedBox(height: 16),

              // ── 4 İstatistik Kartı (KPI) ──
              _buildKpiSection(report, fontBold, fontMedium),
              pw.SizedBox(height: 16),

              // ── Konu Bazlı İlerleme Tablosu ──
              pw.Text(
                'Konu Bazlı Gelişim Durumu',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: textDark,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildTopicTable(report, fontBold, fontMedium),
              pw.SizedBox(height: 16),

              // ── Öğretmen Değerlendirmesi, Güçlü Yönler ve Hedefler ──
              _buildFeedbackSection(report, fontBold, fontMedium, fontItalic),
              pw.Spacer(),

              // ── Footer / Onay & İmza ──
              _buildReportFooter(report, formattedDate, fontBold, fontMedium),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// Başarı Sertifikası (A4 Yatay / Landscape)
  static Future<Uint8List> generateCertificatePdf(
    StudentReport report, {
    Student? student,
  }) async {
    final doc = pw.Document();

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final dateFormat = DateFormat('dd.MM.yyyy');
    final formattedDate = dateFormat.format(report.reportDate);
    final certCode = report.certificateId ??
        'CERT-${report.id.substring(0, report.id.length.clamp(0, 8)).toUpperCase()}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: primaryColor, width: 3),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              color: PdfColors.white,
            ),
            padding: const pw.EdgeInsets.all(12),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: accentColor, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Üst Amblem & Başlık
                  pw.Column(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: const pw.BoxDecoration(
                          color: primaryLight,
                          borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
                        ),
                        child: pw.Text(
                          'DERSHUB EĞİTİM VE GELİŞİM AKADEMİSİ',
                          style: pw.TextStyle(
                            color: primaryDark,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'ÜSTÜN BAŞARI SERTİFİKASI',
                        style: pw.TextStyle(
                          color: textDark,
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'CERTIFICATE OF ACHIEVEMENT',
                        style: pw.TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        width: 140,
                        height: 2,
                        color: accentColor,
                      ),
                    ],
                  ),

                  // Öğrenci Adı ve Başarı Metni
                  pw.Column(
                    children: [
                      pw.Text(
                        'Bu sertifika, üstün gayret ve motivasyonu vesilesiyle',
                        style: pw.TextStyle(fontSize: 12, color: textMuted),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        report.studentName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryDark,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Container(
                        width: 220,
                        height: 1,
                        color: primaryLight,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        constraints: const pw.BoxConstraints(maxWidth: 550),
                        child: pw.Text(
                          report.overallFeedback.isNotEmpty
                              ? report.overallFeedback
                              : 'Sayın ${report.studentName}, ${report.period} süresince gösterdiği üstün başarı, azim ve derslerdeki istikrarlı performansı dolayısıyla bu başarı sertifikasını almaya hak kazanmıştır.',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 11.5,
                            color: textDark,
                            lineSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Alt İmza ve Mühür Bölümü
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Sol: Tarih & Sertifika No
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Sertifika No: $certCode',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: textMuted,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Veriliş Tarihi: $formattedDate',
                            style: pw.TextStyle(fontSize: 9, color: textMuted),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Dönem: ${report.period}',
                            style: pw.TextStyle(fontSize: 9, color: textMuted),
                          ),
                        ],
                      ),

                      // Orta: Altın Rozet / Mühür Sembolü
                      pw.Container(
                        width: 54,
                        height: 54,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: accentColor, width: 2),
                          color: const PdfColor.fromInt(0xFFFFF9EE),
                        ),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'DERSHUB',
                                style: pw.TextStyle(
                                  fontSize: 7,
                                  fontWeight: pw.FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              pw.Text(
                                'ONAYLI',
                                style: pw.TextStyle(
                                  fontSize: 6,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sağ: Eğitmen İmzası
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 140,
                            height: 1,
                            color: textMuted,
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            report.teacherName.isNotEmpty
                                ? report.teacherName
                                : 'Ders Öğretmeni',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          pw.Text(
                            'Eğitmen / Danışman',
                            style: pw.TextStyle(fontSize: 8.5, color: textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  // ──────────────────────────────────────────────
  // RAPOR BİLEŞENLERİ (Helper Widgets)
  // ──────────────────────────────────────────────

  static pw.Widget _buildReportHeader(
    StudentReport report,
    String reportCode,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 40,
              height: 40,
              decoration: const pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Center(
                child: pw.Text(
                  'DH',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DERSHUB',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryDark,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.Text(
                  'Öğrenci Gelişim ve İlerleme Raporu',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const pw.BoxDecoration(
                color: primaryLight,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                report.period,
                style: pw.TextStyle(
                  color: primaryDark,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'Kod: $reportCode',
              style: pw.TextStyle(fontSize: 8, color: textMuted),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildStudentInfoCard(
    StudentReport report,
    Student? student,
    String formattedDate,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: cardBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: borderLight),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Öğrenci:', report.studentName, isBold: true),
                pw.SizedBox(height: 4),
                _infoRow('Sınıf Düzeyi:', student?.gradeLevel ?? 'Belirtilmedi'),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Ders / Branş:', student?.subject ?? 'Özel Ders'),
                pw.SizedBox(height: 4),
                _infoRow('Rapor Tarihi:', formattedDate),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Öğretmen:', report.teacherName.isNotEmpty ? report.teacherName : 'Ders Öğretmeni'),
                pw.SizedBox(height: 4),
                _infoRow('Durum:', student?.isActive == false ? 'Pasif' : 'Aktif Öğrenci', color: successColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Row(
      children: [
        pw.Text(
          '$label ',
          style: pw.TextStyle(fontSize: 8.5, color: textMuted),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? textDark,
            ),
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildKpiSection(
    StudentReport report,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    final avgScoreText = report.averageScore > 0 ? '%${report.averageScore.toStringAsFixed(0)}' : '%85';

    return pw.Row(
      children: [
        _kpiCard('Tamamlanan Ders', '${report.totalLessons}', 'ders', primaryColor),
        pw.SizedBox(width: 8),
        _kpiCard('Toplam Süre', '${report.totalHours}', 'saat', secondaryColor),
        pw.SizedBox(width: 8),
        _kpiCard('İşlenen Konu', '${report.topicProgress.length}', 'konu başlığı', accentColor),
        pw.SizedBox(width: 8),
        _kpiCard('Başarı / Katılım', avgScoreText, 'ortalama', successColor),
      ],
    );
  }

  static pw.Widget _kpiCard(String title, String value, String unit, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: cardBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: borderLight),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 7.5, color: textMuted),
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  value,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
                pw.SizedBox(width: 3),
                pw.Text(
                  unit,
                  style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTopicTable(
    StudentReport report,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    if (report.topicProgress.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: cardBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: borderLight),
        ),
        child: pw.Text(
          'Bu dönem için henüz detaylandırılmış konu kaydı bulunmuyor.',
          style: pw.TextStyle(fontSize: 9, color: textMuted),
        ),
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: borderLight),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: borderLight, width: 0.5),
        ),
        columnWidths: const {
          0: pw.FlexColumnWidth(3.5),
          1: pw.FlexColumnWidth(1.5),
          2: pw.FlexColumnWidth(2.0),
          3: pw.FlexColumnWidth(2.5),
        },
        children: [
          // Table Header
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: primaryLight,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
            ),
            children: [
              _tableCell('Konu Adı', isHeader: true),
              _tableCell('Ders Sayısı', isHeader: true, align: pw.TextAlign.center),
              _tableCell('Seviye', isHeader: true, align: pw.TextAlign.center),
              _tableCell('Yetkinlik Skoru', isHeader: true, align: pw.TextAlign.right),
            ],
          ),
          // Table Rows
          ...report.topicProgress.map((tp) {
            PdfColor levelColor = accentColor;
            if (tp.level == 'İleri') {
              levelColor = successColor;
            } else if (tp.level == 'Başlangıç') {
              levelColor = dangerColor;
            }

            final pct = (tp.proficiency * 100).toInt();

            return pw.TableRow(
              children: [
                _tableCell(tp.topic, isBold: true),
                _tableCell('${tp.lessonsCount} ders', align: pw.TextAlign.center),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  alignment: pw.Alignment.center,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: levelColor.flatten(),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      tp.level,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  alignment: pw.Alignment.centerRight,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 50,
                        height: 6,
                        decoration: const pw.BoxDecoration(
                          color: borderLight,
                          borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                        ),
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Container(
                            width: (50 * tp.proficiency.clamp(0.0, 1.0)),
                            height: 6,
                            decoration: pw.BoxDecoration(
                              color: levelColor,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        '%$pct',
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 8.5 : 8.5,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? primaryDark : textDark,
        ),
      ),
    );
  }

  static pw.Widget _buildFeedbackSection(
    StudentReport report,
    pw.Font fontBold,
    pw.Font fontMedium,
    pw.Font fontItalic,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Sol Kolon: Güçlü Yönler & Gelişim Alanları
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (report.strengths.isNotEmpty) ...[
                pw.Text(
                  'Öne Çıkan Güçlü Yönler',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: successColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...report.strengths.map(
                  (s) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: pw.TextStyle(color: successColor, fontSize: 10)),
                        pw.Expanded(
                          child: pw.Text(
                            s,
                            style: pw.TextStyle(fontSize: 8.5, color: textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
              ],
              if (report.areasForImprovement.isNotEmpty) ...[
                pw.Text(
                  'Geliştirilmesi Gereken Hedef Alanlar',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...report.areasForImprovement.map(
                  (a) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: pw.TextStyle(color: accentColor, fontSize: 10)),
                        pw.Expanded(
                          child: pw.Text(
                            a,
                            style: pw.TextStyle(fontSize: 8.5, color: textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(width: 14),

        // Sağ Kolon: Öğretmenin Genel Değerlendirmesi
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: cardBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: borderLight),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Öğretmenin Genel Görüşü',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  report.overallFeedback.isNotEmpty
                      ? report.overallFeedback
                      : 'Öğrencimiz bu dönem derslere düzenli katılım göstermiş ve çalışma disipliniyle hedeflerine adım adım ilerlemiştir.',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    color: textDark,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildReportFooter(
    StudentReport report,
    String formattedDate,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderLight, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DersHub Dijital Raporlama Sistemi',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              pw.Text(
                'Bu rapor eğitmen tarafından hazırlanmış olup sistem onaylıdır.',
                style: pw.TextStyle(fontSize: 7, color: textMuted),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Eğitmen Onayı',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: textMuted,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                report.teacherName.isNotEmpty ? report.teacherName : 'Ders Öğretmeni',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // DOSYA VE PAYLAŞIM FONKSİYONLARI
  // ──────────────────────────────────────────────

  /// PDF baytlarını geçici dizine dosya olarak yazar
  static Future<File> savePdfToFile(Uint8List bytes, String filename) async {
    final output = await getTemporaryDirectory();
    final sanitizedName = filename.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
    final file = File('${output.path}/$sanitizedName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// PDF dosyasını açar
  static Future<void> openPdfFile(File file) async {
    await OpenFilex.open(file.path);
  }

  /// PDF dosyasını sistem paylaşım menüsüyle paylaşır (WhatsApp, Mail vb.)
  static Future<void> sharePdfFile(
    Uint8List bytes,
    String filename, {
    String? subject,
    String? text,
  }) async {
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: '$filename.pdf',
      );
    } catch (_) {
      final file = await savePdfToFile(bytes, filename);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text ?? 'Öğrenci Gelişim Raporu (DersHub)',
          subject: subject ?? 'DersHub İlerleme Raporu',
        ),
      );
    }
  }
}
