import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/lesson.dart';
import '../../models/report.dart';
import '../../models/student.dart';
import '../../models/teacher.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import 'pdf_preview_screen.dart';

class CreateReportDialog extends ConsumerStatefulWidget {
  final Student student;
  final List<Lesson> lessons;
  final bool initialIsCertificate;

  const CreateReportDialog({
    super.key,
    required this.student,
    required this.lessons,
    this.initialIsCertificate = false,
  });

  static Future<void> show(
    BuildContext context, {
    required Student student,
    required List<Lesson> lessons,
    bool isCertificate = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateReportDialog(
        student: student,
        lessons: lessons,
        initialIsCertificate: isCertificate,
      ),
    );
  }

  @override
  ConsumerState<CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends ConsumerState<CreateReportDialog> {
  late bool _isCertificate;
  late TextEditingController _titleController;
  late TextEditingController _periodController;
  late TextEditingController _feedbackController;
  late TextEditingController _newStrengthController;
  late TextEditingController _newAreaController;

  late List<String> _strengths;
  late List<String> _areasForImprovement;
  late List<TopicProgress> _topicProgress;
  int _totalLessons = 0;
  int _totalHours = 0;
  double _score = 85.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isCertificate = widget.initialIsCertificate;
    _newStrengthController = TextEditingController();
    _newAreaController = TextEditingController();

    _initializeFromDraft();
  }

  void _initializeFromDraft() {
    final reportService = ref.read(reportServiceProvider);
    final user = ref.read(authServiceProvider).getCurrentUser();
    final teacherName = user is Teacher ? user.fullName : 'Ders Öğretmeni';

    if (_isCertificate) {
      final draft = reportService.createCertificateDraft(
        student: widget.student,
        teacherName: teacherName,
        certificateTitle: '${widget.student.subject} Başarı Sertifikası',
      );
      _titleController = TextEditingController(text: draft.title);
      _periodController = TextEditingController(text: draft.period);
      _feedbackController = TextEditingController(text: draft.overallFeedback);
      _strengths = [];
      _areasForImprovement = [];
      _topicProgress = [];
      _totalLessons = 0;
      _totalHours = 0;
      _score = 100.0;
    } else {
      final draft = reportService.createMonthlyReportDraft(
        student: widget.student,
        lessons: widget.lessons,
        teacherName: teacherName,
      );
      _titleController = TextEditingController(text: draft.title);
      _periodController = TextEditingController(text: draft.period);
      _feedbackController = TextEditingController(text: draft.overallFeedback);
      _strengths = List.from(draft.strengths);
      _areasForImprovement = List.from(draft.areasForImprovement);
      _topicProgress = List.from(draft.topicProgress);
      _totalLessons = draft.totalLessons;
      _totalHours = draft.totalHours;
      _score = draft.averageScore;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _periodController.dispose();
    _feedbackController.dispose();
    _newStrengthController.dispose();
    _newAreaController.dispose();
    super.dispose();
  }

  StudentReport _buildReportObject() {
    final user = ref.read(authServiceProvider).getCurrentUser();
    final teacherName = user is Teacher ? user.fullName : 'Ders Öğretmeni';
    final now = DateTime.now();
    final certId = _isCertificate
        ? 'DHB-CERT-${now.year}-${widget.student.id.substring(0, widget.student.id.length.clamp(0, 4)).toUpperCase()}-${now.millisecond}'
        : 'DHB-RAP-${now.year}${now.month.toString().padLeft(2, '0')}-${widget.student.id.substring(0, widget.student.id.length.clamp(0, 4)).toUpperCase()}';

    return StudentReport(
      id: '',
      teacherId: user?.id ?? 'mock_teacher_id',
      studentId: widget.student.id,
      studentName: widget.student.nickname,
      teacherName: teacherName,
      reportDate: now,
      period: _periodController.text.trim().isNotEmpty
          ? _periodController.text.trim()
          : DateFormat('MMMM yyyy', 'tr_TR').format(now),
      totalLessons: _totalLessons,
      totalHours: _totalHours,
      topicProgress: _topicProgress,
      overallFeedback: _feedbackController.text.trim(),
      strengths: _strengths,
      areasForImprovement: _areasForImprovement,
      averageScore: _score,
      reportType: _isCertificate ? 'certificate' : 'progress_report',
      certificateId: certId,
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : (_isCertificate ? 'Başarı Sertifikası' : 'Aylık İlerleme Raporu'),
      createdAt: now,
    );
  }

  Future<void> _saveReport() async {
    setState(() => _isLoading = true);
    try {
      final report = _buildReportObject();
      final saved = await ref.read(reportServiceProvider).saveReport(report);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCertificate
                ? 'Başarı sertifikası oluşturuldu!'
                : 'Aylık gelişim raporu kaydedildi!',
          ),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'PDF Önizle',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfPreviewScreen(
                    report: saved,
                    student: widget.student,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt sırasında hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _previewDirectly() {
    final report = _buildReportObject();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(
          report: report,
          student: widget.student,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCertificate ? 'Başarı Sertifikası Ver' : 'Yeni İlerleme Raporu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.student.nickname,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          // Type Toggle Segmented Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 6),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Gelişim Raporu'),
                  icon: Icon(Icons.analytics_outlined),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Sertifika'),
                  icon: Icon(Icons.workspace_premium_outlined),
                ),
              ],
              selected: {_isCertificate},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isCertificate = newSelection.first;
                  _initializeFromDraft();
                });
              },
            ),
          ),

          const Divider(),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık & Dönem
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Rapor / Belge Başlığı',
                            prefixIcon: Icon(Icons.title_rounded, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _periodController,
                          decoration: const InputDecoration(
                            labelText: 'Dönem',
                            prefixIcon: Icon(Icons.calendar_month_rounded, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!_isCertificate) ...[
                    // İstatistik Özet Kutusu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('Tamamlanan Ders', '$_totalLessons', Icons.school_outlined),
                          _statItem('Toplam Süre', '$_totalHours saat', Icons.access_time_rounded),
                          _statItem('Konu Başlığı', '${_topicProgress.length}', Icons.menu_book_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Başarı Oranı Slider
                    Text(
                      'Genel Başarı / Katılım Skoru: %${_score.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Slider(
                      value: _score,
                      min: 40,
                      max: 100,
                      divisions: 12,
                      activeColor: AppColors.primary,
                      label: '%${_score.toInt()}',
                      onChanged: (val) => setState(() => _score = val),
                    ),
                    const SizedBox(height: 16),

                    // Güçlü Yönler
                    _buildSectionHeader('Güçlü Yönler', Icons.thumb_up_alt_outlined, AppColors.success),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _strengths
                          .map(
                            (s) => Chip(
                              label: Text(s, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.success.withAlpha(25),
                              deleteIconColor: AppColors.success,
                              onDeleted: () {
                                setState(() => _strengths.remove(s));
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newStrengthController,
                            decoration: const InputDecoration(
                              hintText: 'Yeni güçlü yön ekle...',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () {
                            final text = _newStrengthController.text.trim();
                            if (text.isNotEmpty) {
                              setState(() {
                                _strengths.add(text);
                                _newStrengthController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Gelişim Alanları
                    _buildSectionHeader('Gelişim Hedefleri', Icons.track_changes_rounded, AppColors.warning),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _areasForImprovement
                          .map(
                            (a) => Chip(
                              label: Text(a, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.warning.withAlpha(25),
                              deleteIconColor: AppColors.warning,
                              onDeleted: () {
                                setState(() => _areasForImprovement.remove(a));
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newAreaController,
                            decoration: const InputDecoration(
                              hintText: 'Geliştirilecek alan ekle...',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () {
                            final text = _newAreaController.text.trim();
                            if (text.isNotEmpty) {
                              setState(() {
                                _areasForImprovement.add(text);
                                _newAreaController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Öğretmen Genel Değerlendirmesi / Sertifika Metni
                  Text(
                    _isCertificate ? 'Sertifika Tebrik ve Başarı Metni' : 'Öğretmenin Genel Görüşü & Notu',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: _isCertificate
                          ? 'Öğrencinin başarısını ve tamamlanan programı özetleyen tebrik mesajı...'
                          : 'Öğrencinin ders motivasyonu, performansı ve tavsiyeler...',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previewDirectly,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('PDF Önizle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveReport,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isLoading ? 'Kaydediliyor...' : 'Kaydet ve Oluştur'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color),
        ),
      ],
    );
  }
}
