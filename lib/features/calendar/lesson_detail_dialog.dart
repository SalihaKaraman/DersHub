import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/lesson.dart';
import '../../models/lesson_status.dart';
import '../../models/fee_policy.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../services/messaging_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LessonDetailDialog
//  FAZ 1: 6 durumlu grid seçici + ücret önizlemesi
//  FAZ 2: Ayrı "İptal Et" ve "Ertele" aksiyon butonları + mesaj şablonları
// ─────────────────────────────────────────────────────────────────────────────

class LessonDetailDialog extends ConsumerStatefulWidget {
  final Lesson lesson;
  final Student? student;

  const LessonDetailDialog({
    super.key,
    required this.lesson,
    this.student,
  });

  static Future<void> show(
    BuildContext context,
    Lesson lesson, {
    Student? student,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LessonDetailDialog(
        lesson: lesson,
        student: student,
      ),
    );
  }

  @override
  ConsumerState<LessonDetailDialog> createState() => _LessonDetailDialogState();
}

class _LessonDetailDialogState extends ConsumerState<LessonDetailDialog> {
  late LessonStatus _selectedStatus;
  late TextEditingController _reasonController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.lesson.lessonStatus;
    _reasonController = TextEditingController(
      text: widget.lesson.cancellationReason ?? '',
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Student? _resolveStudent() {
    if (widget.student != null) return widget.student;
    final students = ref.read(studentsStreamProvider).value;
    return students?.cast<Student?>().firstWhere(
          (s) => s?.id == widget.lesson.studentId,
          orElse: () => null,
        );
  }

  FeePolicy _resolvePolicy(Student? student) {
    final globalPolicy =
        ref.read(feePolicyStreamProvider).value ?? const FeePolicy();
    return student?.resolvePolicy(globalPolicy) ?? globalPolicy;
  }

  // ── Status update (FAZ 1 flow) ───────────────────────────────────────────

  Future<void> _updateStatus(FeePolicy policy) async {
    setState(() => _isSaving = true);
    try {
      final reason = _reasonController.text.trim();
      await ref.read(databaseServiceProvider).updateLessonStatus(
            lessonId: widget.lesson.id,
            newStatus: _selectedStatus,
            reason: reason.isNotEmpty ? reason : null,
            statusUpdatedAt: DateTime.now(),
            explicitPolicy: policy,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ders durumu "${_selectedStatus.displayName}" olarak güncellendi.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> _deleteLesson() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dersi Sil'),
        content: const Text(
          'Bu ders kaydı kalıcı olarak silinecektir. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(databaseServiceProvider).deleteLesson(widget.lesson.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ders silindi.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FAZ 2: İPTAL BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────────────

  void _showCancelSheet() {
    final student = _resolveStudent();
    final policy = _resolvePolicy(student);

    // Local state for bottom sheet
    LessonStatus cancelledBy = LessonStatus.cancelledByStudent;
    final reasonCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final feePreview = policy.calculateCharge(
            lessonPrice: widget.lesson.price,
            lessonDateTime: widget.lesson.dateTime,
            status: cancelledBy,
            statusUpdatedAt: DateTime.now(),
          );
          final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;

          return _SheetWrapper(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Dersi İptal Et',
                  style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.p20),

                // Kim iptal etti
                Text('Kim iptal etti?',
                    style: Theme.of(sheetCtx)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _CancellerButton(
                        label: 'Öğrenci',
                        icon: Icons.person_off_rounded,
                        selected:
                            cancelledBy == LessonStatus.cancelledByStudent,
                        color: AppColors.warning,
                        onTap: () => setSheetState(() =>
                            cancelledBy = LessonStatus.cancelledByStudent),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CancellerButton(
                        label: 'Öğretmen',
                        icon: Icons.person_off_outlined,
                        selected:
                            cancelledBy == LessonStatus.cancelledByTeacher,
                        color: AppColors.error,
                        onTap: () => setSheetState(() =>
                            cancelledBy = LessonStatus.cancelledByTeacher),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Sebep
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Sebep (İsteğe bağlı)',
                    hintText: 'Örn: Öğrenci rahatsızlandı…',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: AppSizes.p16),

                // Ücret etkisi önizleme
                _FeePreviewCard(
                  status: cancelledBy,
                  feeResult: feePreview,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSizes.p20),

                // Onayla butonu
                FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          setSheetState(() => saving = true);
                          try {
                            await ref
                                .read(databaseServiceProvider)
                                .updateLessonStatus(
                                  lessonId: widget.lesson.id,
                                  newStatus: cancelledBy,
                                  reason: reasonCtrl.text.trim().isNotEmpty
                                      ? reasonCtrl.text.trim()
                                      : null,
                                  statusUpdatedAt: DateTime.now(),
                                  explicitPolicy: policy,
                                );

                            if (!sheetCtx.mounted) return;
                            Navigator.pop(sheetCtx); // close cancel sheet
                            if (!mounted) return;
                            Navigator.pop(context); // close main sheet

                            // Mesaj butonları
                            if (student?.phoneNumber?.isNotEmpty == true) {
                              _showPostActionMessageButtons(
                                context: context,
                                student: student!,
                                label: 'İptal bildirimi gönderilsin mi?',
                                onWhatsApp: () => ref
                                    .read(messagingServiceProvider)
                                    .sendCancellationWhatsApp(
                                      student: student,
                                      lesson: widget.lesson,
                                      cancelledBy: cancelledBy,
                                      reason: reasonCtrl.text.trim().isNotEmpty
                                          ? reasonCtrl.text.trim()
                                          : null,
                                    ),
                                onSms: () => ref
                                    .read(messagingServiceProvider)
                                    .sendCancellationSms(
                                      student: student,
                                      lesson: widget.lesson,
                                      cancelledBy: cancelledBy,
                                      reason: reasonCtrl.text.trim().isNotEmpty
                                          ? reasonCtrl.text.trim()
                                          : null,
                                    ),
                              );
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Ders ${cancelledBy.displayName} olarak işaretlendi.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            setSheetState(() => saving = false);
                            if (!sheetCtx.mounted) return;
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(
                                content: Text('Hata: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_rounded),
                  label: const Text('İptali Onayla'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: const Text('Vazgeç'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FAZ 2: ERTELEME BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────────────

  void _showRescheduleSheet() {
    final student = _resolveStudent();

    DateTime selectedDate = widget.lesson.dateTime.add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(widget.lesson.dateTime);
    final reasonCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
          final newDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          return _SheetWrapper(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Dersi Ertele',
                  style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Orijinal: ${AppHelpers.formatDate(widget.lesson.dateTime)} '
                  '${AppHelpers.formatTime(widget.lesson.dateTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.p20),

                // Tarih seçici
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Yeni Tarih: ${AppHelpers.formatDate(selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: sheetCtx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: const Text('Değiştir'),
                    ),
                  ],
                ),
                const Divider(height: 1),

                // Saat seçici
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Yeni Saat: ${selectedTime.format(sheetCtx)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: sheetCtx,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setSheetState(() => selectedTime = picked);
                        }
                      },
                      child: const Text('Değiştir'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Sebep
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Erteleme Sebebi (İsteğe bağlı)',
                    hintText: 'Örn: Sınav haftası, tatil…',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: AppSizes.p20),

                // Ertele butonu
                FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          setSheetState(() => saving = true);
                          try {
                            await ref
                                .read(databaseServiceProvider)
                                .rescheduleLesson(
                                  originalLessonId: widget.lesson.id,
                                  newDateTime: newDateTime,
                                  reason: reasonCtrl.text.trim().isNotEmpty
                                      ? reasonCtrl.text.trim()
                                      : null,
                                );

                            if (!sheetCtx.mounted) return;
                            Navigator.pop(sheetCtx);
                            if (!mounted) return;
                            Navigator.pop(context);

                            // Mesaj butonları
                            if (student?.phoneNumber?.isNotEmpty == true) {
                              _showPostActionMessageButtons(
                                context: context,
                                student: student!,
                                label: 'Erteleme bildirimi gönderilsin mi?',
                                onWhatsApp: () => ref
                                    .read(messagingServiceProvider)
                                    .sendRescheduleWhatsApp(
                                      student: student,
                                      originalLesson: widget.lesson,
                                      newDateTime: newDateTime,
                                      reason: reasonCtrl.text.trim().isNotEmpty
                                          ? reasonCtrl.text.trim()
                                          : null,
                                    ),
                                onSms: () => ref
                                    .read(messagingServiceProvider)
                                    .sendRescheduleSms(
                                      student: student,
                                      originalLesson: widget.lesson,
                                      newDateTime: newDateTime,
                                      reason: reasonCtrl.text.trim().isNotEmpty
                                          ? reasonCtrl.text.trim()
                                          : null,
                                    ),
                              );
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ders ertelendi, yeni ders oluşturuldu.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            setSheetState(() => saving = false);
                            if (!sheetCtx.mounted) return;
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(
                                content: Text('Hata: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.update_rounded),
                  label: const Text('Ertelemeyi Onayla'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: const Text('Vazgeç'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FAZ 2: Mesaj butonları (iptal/erteleme sonrası)
  // ─────────────────────────────────────────────────────────────────────────

  void _showPostActionMessageButtons({
    required BuildContext context,
    required Student student,
    required String label,
    required VoidCallback onWhatsApp,
    required VoidCallback onSms,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 6),
        action: null,
        // Yerine bir dialog aç
      ),
    );
    // Bildirim için dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Öğrenciye Bildirim'),
        content: Text('$label\n\nÖğrenci: ${student.nickname}'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onSms();
            },
            icon: const Icon(Icons.sms_rounded),
            label: const Text('SMS'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onWhatsApp();
            },
            icon: const Icon(Icons.message_rounded),
            label: const Text('WhatsApp'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Atla'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve student & fee policy
    final students = ref.watch(studentsStreamProvider).value;
    final resolvedStudent = widget.student ??
        students?.cast<Student?>().firstWhere(
              (s) => s?.id == widget.lesson.studentId,
              orElse: () => null,
            );
    final globalPolicy =
        ref.watch(feePolicyStreamProvider).value ?? const FeePolicy();
    final effectivePolicy =
        resolvedStudent?.resolvePolicy(globalPolicy) ?? globalPolicy;

    // Calculate fee preview based on currently selected status in dialog
    final feePreview = effectivePolicy.calculateCharge(
      lessonPrice: widget.lesson.price,
      lessonDateTime: widget.lesson.dateTime,
      status: _selectedStatus,
      statusUpdatedAt: DateTime.now(),
    );

    final needsReasonInput = _selectedStatus ==
            LessonStatus.cancelledByStudent ||
        _selectedStatus == LessonStatus.cancelledByTeacher ||
        _selectedStatus == LessonStatus.rescheduled;

    final lesson = widget.lesson;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.r24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header indicator bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.p16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title & Close
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.studentName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lesson.topic.isNotEmpty ? lesson.topic : 'Özel Ders',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // ── FAZ 2: Erteleme/Telafi Geçmişi Chip'leri ──────────────────
              if (lesson.isCompensation) ...[
                const SizedBox(height: 8),
                _InfoChip(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Bu ders bir telafi dersidir.',
                  color: AppColors.primary,
                ),
              ],
              if (lesson.rescheduleFromLessonId != null) ...[
                const SizedBox(height: 8),
                _InfoChip(
                  icon: Icons.update_rounded,
                  label: 'Bu ders bir erteleme sonucu oluştu.',
                  color: AppColors.warning,
                ),
              ],
              if (lesson.rescheduleToLessonId != null) ...[
                const SizedBox(height: 8),
                _InfoChip(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Bu ders ertelendi (yeni ders oluşturuldu).',
                  color: AppColors.textSecondaryLight,
                ),
              ],

              const SizedBox(height: AppSizes.p16),

              // Info chips row
              Container(
                padding: const EdgeInsets.all(AppSizes.p12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppSizes.r16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tarih',
                      value: AppHelpers.formatDate(lesson.dateTime),
                    ),
                    _buildInfoColumn(
                      icon: Icons.schedule_rounded,
                      label: 'Saat / Süre',
                      value:
                          '${AppHelpers.formatTime(lesson.dateTime)} · ${lesson.durationMinutes} dk',
                    ),
                    _buildInfoColumn(
                      icon: Icons.payments_rounded,
                      label: 'Ders Ücreti',
                      value: lesson.isCompensation
                          ? 'Telafi (Ücretsiz)'
                          : AppHelpers.formatCurrency(lesson.price),
                      valueColor:
                          lesson.isCompensation ? AppColors.primary : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p16),

              // ── FAZ 2: Hızlı Aksiyon Butonları ────────────────────────────
              if (!lesson.isCancelled &&
                  lesson.lessonStatus != LessonStatus.rescheduled) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showCancelSheet,
                        icon: const Icon(Icons.cancel_outlined,
                            color: AppColors.error, size: 18),
                        label: const Text('İptal Et',
                            style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.r12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showRescheduleSheet,
                        icon: const Icon(Icons.update_rounded,
                            color: AppColors.warning, size: 18),
                        label: const Text('Ertele',
                            style: TextStyle(color: AppColors.warning)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.warning),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.r12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                const Divider(),
                const SizedBox(height: 8),
              ],

              // Lesson Status Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ders Durumu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: lesson.lessonStatus.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          lesson.lessonStatus.icon,
                          size: 14,
                          color: lesson.lessonStatus.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mevcut: ${lesson.lessonStatus.displayName}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: lesson.lessonStatus.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p12),

              // Status Grid Selector
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: LessonStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  return InkWell(
                    onTap: () => setState(() => _selectedStatus = status),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? status.color.withValues(alpha: 0.16)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        border: Border.all(
                          color: isSelected
                              ? status.color
                              : (isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(status.icon, color: status.color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              status.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? status.color : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: status.color,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.p16),

              // Fee Impact Preview Card
              _FeePreviewCard(
                status: _selectedStatus,
                feeResult: feePreview,
                isDark: isDark,
              ),

              if (needsReasonInput) ...[
                const SizedBox(height: AppSizes.p16),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'İptal / Erteleme Sebebi (İsteğe bağlı)',
                    hintText: 'Örn: Öğrenci rahatsızlandı, sınav haftası vb.',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.p24),

              // Action buttons
              FilledButton.icon(
                onPressed:
                    _isSaving ? null : () => _updateStatus(effectivePolicy),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _selectedStatus == lesson.lessonStatus
                      ? 'Durumu Onayla'
                      : 'Durumu "${_selectedStatus.displayName}" Yap',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedStatus.color,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r16),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.p12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteLesson,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                      label: const Text(
                        'Dersi Sil',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kapat'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Paylaşılan küçük widget'lar
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom sheet için ortak sarmalayıcı
class _SheetWrapper extends StatelessWidget {
  final Widget child;
  const _SheetWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: EdgeInsets.only(
        left: AppSizes.p20,
        right: AppSizes.p20,
        top: AppSizes.p20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.p20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.r24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

/// Ücret etkisi önizleme kartı
class _FeePreviewCard extends StatelessWidget {
  final LessonStatus status;
  final FeeCalculationResult feeResult;
  final bool isDark;

  const _FeePreviewCard({
    required this.status,
    required this.feeResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            status.color.withValues(alpha: 0.12),
            status.color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, size: 18, color: status.color),
              const SizedBox(width: 8),
              Text(
                'Ücret Etkisi Önizlemesi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: status.color,
                ),
              ),
              const Spacer(),
              Text(
                AppHelpers.formatCurrency(feeResult.calculatedCharge),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: status.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            feeResult.description,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (feeResult.createsCompensation) ...[
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.card_giftcard_rounded,
                    size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Öğrenciye 1 telafi hakkı oluşturulacaktır.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// İptal eden kişi seçim butonu
class _CancellerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CancellerButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.r12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color : null,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bilgi chip'i (erteleme/telafi geçmişi)
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
