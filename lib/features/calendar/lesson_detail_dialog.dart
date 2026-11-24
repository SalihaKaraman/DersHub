import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/lesson.dart';
import '../../models/lesson_status.dart';
import '../../models/fee_policy.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';

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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
        await ref
            .read(databaseServiceProvider)
            .deleteLesson(widget.lesson.id);
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
                          widget.lesson.studentName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.lesson.topic.isNotEmpty
                              ? widget.lesson.topic
                              : 'Özel Ders',
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
                      value: AppHelpers.formatDate(widget.lesson.dateTime),
                    ),
                    _buildInfoColumn(
                      icon: Icons.schedule_rounded,
                      label: 'Saat / Süre',
                      value:
                          '${AppHelpers.formatTime(widget.lesson.dateTime)} · ${widget.lesson.durationMinutes} dk',
                    ),
                    _buildInfoColumn(
                      icon: Icons.payments_rounded,
                      label: 'Ders Ücreti',
                      value: AppHelpers.formatCurrency(widget.lesson.price),
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p20),

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
                      color: widget.lesson.lessonStatus.color
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.lesson.lessonStatus.icon,
                          size: 14,
                          color: widget.lesson.lessonStatus.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mevcut: ${widget.lesson.lessonStatus.displayName}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.lesson.lessonStatus.color,
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
                    onTap: () {
                      setState(() => _selectedStatus = status);
                    },
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
                              : (isDark ? Colors.white12 : Colors.grey.shade300),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status.icon,
                            color: status.color,
                            size: 20,
                          ),
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
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedStatus.color.withValues(alpha: 0.12),
                      _selectedStatus.color.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.r16),
                  border: Border.all(
                    color: _selectedStatus.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: 18,
                          color: _selectedStatus.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ücret Etkisi Önizlemesi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _selectedStatus.color,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppHelpers.formatCurrency(feePreview.calculatedCharge),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _selectedStatus.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feePreview.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (feePreview.createsCompensation) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.card_giftcard_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
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
                onPressed: _isSaving ? null : () => _updateStatus(effectivePolicy),
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
                  _selectedStatus == widget.lesson.lessonStatus
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
