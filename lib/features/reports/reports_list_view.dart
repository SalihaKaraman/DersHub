import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/lesson.dart';
import '../../models/report.dart';
import '../../models/student.dart';
import '../../services/pdf_generator_service.dart';
import '../../services/report_service.dart';
import 'create_report_dialog.dart';
import 'pdf_preview_screen.dart';

class ReportsListView extends ConsumerWidget {
  final Student student;
  final List<Lesson> lessons;
  final bool isTeacher;

  const ReportsListView({
    super.key,
    required this.student,
    required this.lessons,
    this.isTeacher = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportsAsync = ref.watch(studentReportsStreamProvider(student.id));

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Raporlar yüklenemedi: $e')),
      data: (reports) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Üst Eylem ve Bilgilendirme Kartı ──
              _buildTopHeaderCard(context, reports.length, isDark),
              const SizedBox(height: 16),

              if (reports.isEmpty)
                _buildEmptyState(context, isDark)
              else ...[
                Text(
                  'Kayıtlı Raporlar ve Belgeler (${reports.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportCard(context, ref, report, isDark);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHeaderCard(BuildContext context, int totalCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.r20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Raporlar & Sertifikalar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isTeacher
                            ? 'Öğrenciye özel PDF çıktısı oluşturun'
                            : 'Öğretmen tarafından hazırlanan resmi belgeler',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCount Belge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (isTeacher) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                    ),
                    onPressed: () {
                      CreateReportDialog.show(
                        context,
                        student: student,
                        lessons: lessons,
                        isCertificate: false,
                      );
                    },
                    icon: const Icon(Icons.add_chart_rounded, size: 18),
                    label: const Text(
                      '+ Gelişim Raporu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                    ),
                    onPressed: () {
                      CreateReportDialog.show(
                        context,
                        student: student,
                        lessons: lessons,
                        isCertificate: true,
                      );
                    },
                    icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                    label: const Text(
                      '+ Sertifika Ver',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 54,
            color: AppColors.primary.withAlpha(120),
          ),
          const SizedBox(height: 14),
          const Text(
            'Henüz Rapor veya Belge Bulunmuyor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            isTeacher
                ? 'Öğrencinin işlediği dersleri özetleyen bir Aylık Gelişim Raporu oluşturabilir veya başarı sertifikası düzenleyebilirsiniz.'
                : 'Öğretmeniniz öğrencinin gelişimine dair rapor veya sertifika hazırladığında burada listelenecektir.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
          ),
          if (isTeacher) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                CreateReportDialog.show(
                  context,
                  student: student,
                  lessons: lessons,
                  isCertificate: false,
                );
              },
              icon: const Icon(Icons.note_add_rounded),
              label: const Text('İlk Raporu Oluştur'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    WidgetRef ref,
    StudentReport report,
    bool isDark,
  ) {
    final isCert = report.reportType == 'certificate';
    final dateStr = DateFormat('dd.MM.yyyy', 'tr_TR').format(report.reportDate);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(
          color: isCert
              ? AppColors.accent.withAlpha(120)
              : (isDark ? Colors.white10 : Colors.black12),
          width: isCert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Bant / Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCert
                  ? AppColors.accent.withAlpha(25)
                  : AppColors.primary.withAlpha(20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCert
                          ? Icons.workspace_premium_rounded
                          : Icons.insights_rounded,
                      size: 20,
                      color: isCert ? AppColors.accent : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCert ? 'BAŞARI SERTİFİKASI' : 'AYLIK GELİŞİM RAPORU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: isCert ? Colors.amber.shade800 : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white70,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.period,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tarih: $dateStr • ${report.certificateId ?? ""}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isCert && report.averageScore > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '%${report.averageScore.toInt()} Başarı',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),

                if (!isCert) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _badge('${report.totalLessons} Ders', Icons.school_outlined),
                      _badge('${report.totalHours} Saat', Icons.timer_outlined),
                      _badge('${report.topicProgress.length} Konu', Icons.menu_book_outlined),
                    ],
                  ),
                ],

                if (report.overallFeedback.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    report.overallFeedback,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isTeacher) ...[
                      IconButton(
                        tooltip: 'Raporu Sil',
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                        onPressed: () => _confirmDelete(context, ref, report.id),
                      ),
                    ],
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () async {
                        try {
                          final bytes = isCert
                              ? await PdfGeneratorService.generateCertificatePdf(report, student: student)
                              : await PdfGeneratorService.generateProgressReportPdf(report, student: student);
                          final filename = '${report.studentName}_${report.period}_${isCert ? "Sertifika" : "Rapor"}';
                          await PdfGeneratorService.sharePdfFile(
                            bytes,
                            filename,
                            subject: '${report.studentName} - ${report.title}',
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Paylaşım hatası: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Paylaş', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreviewScreen(
                              report: report,
                              student: student,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: const Text('PDF Görüntüle', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 14, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.primaryLight.withAlpha(40),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String reportId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Raporu Sil'),
        content: const Text('Bu raporu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(reportServiceProvider).deleteReport(reportId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rapor silindi.')),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
