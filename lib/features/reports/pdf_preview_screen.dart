import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/constants.dart';
import '../../models/report.dart';
import '../../models/student.dart';
import '../../services/pdf_generator_service.dart';

class PdfPreviewScreen extends StatelessWidget {
  final StudentReport report;
  final Student? student;

  const PdfPreviewScreen({
    super.key,
    required this.report,
    this.student,
  });

  @override
  Widget build(BuildContext context) {
    final isCert = report.reportType == 'certificate';
    final title = isCert ? 'Başarı Sertifikası Önizleme' : 'İlerleme Raporu Önizleme';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'PDF Paylaş',
            onPressed: () async {
              try {
                final bytes = isCert
                    ? await PdfGeneratorService.generateCertificatePdf(report, student: student)
                    : await PdfGeneratorService.generateProgressReportPdf(report, student: student);
                final filename = '${report.studentName}_${report.period}_${isCert ? "Sertifika" : "Rapor"}';
                await PdfGeneratorService.sharePdfFile(
                  bytes,
                  filename,
                  subject: '${report.studentName} - $title',
                  text: 'DersHub: ${report.studentName} öğrencimize ait $title ektedir.',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Paylaşım sırasında hata oluştu: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _buildPdf(format),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName:
            '${report.studentName}_${report.period}_${isCert ? "Sertifika" : "Rapor"}.pdf',
        previewPageMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        loadingWidget: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                'PDF Oluşturuluyor...',
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _buildPdf(dynamic format) {
    if (report.reportType == 'certificate') {
      return PdfGeneratorService.generateCertificatePdf(report, student: student);
    }
    return PdfGeneratorService.generateProgressReportPdf(report, student: student);
  }
}
