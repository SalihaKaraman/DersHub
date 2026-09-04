import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/group_lesson.dart';
import '../../services/group_lesson_service.dart';

class GroupLessonDetailDialog extends ConsumerStatefulWidget {
  final GroupLesson lesson;

  const GroupLessonDetailDialog({super.key, required this.lesson});

  static Future<void> show(BuildContext context, GroupLesson lesson) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GroupLessonDetailDialog(lesson: lesson),
    );
  }

  @override
  ConsumerState<GroupLessonDetailDialog> createState() =>
      _GroupLessonDetailDialogState();
}

class _GroupLessonDetailDialogState
    extends ConsumerState<GroupLessonDetailDialog> {
  late bool _isCompleted;
  late List<GroupLessonNote> _notes;
  late Map<String, TextEditingController> _noteControllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.lesson.isCompleted;

    // Eğer individualNotes henüz oluşmamışsa studentIds'ten oluştur
    if (widget.lesson.individualNotes.isNotEmpty) {
      _notes = widget.lesson.individualNotes.map((n) => n).toList();
    } else {
      _notes = List.generate(widget.lesson.studentIds.length, (i) {
        final id = widget.lesson.studentIds[i];
        final name = i < widget.lesson.studentNames.length
            ? widget.lesson.studentNames[i]
            : 'Öğrenci';
        return GroupLessonNote(
          studentId: id,
          studentName: name,
          attended: true,
          personalNote: '',
        );
      });
    }

    _noteControllers = {
      for (final note in _notes)
        note.studentId: TextEditingController(text: note.personalNote),
    };
  }

  @override
  void dispose() {
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleCompletion(bool val) async {
    setState(() => _isCompleted = val);
    await ref
        .read(groupLessonServiceProvider)
        .toggleLessonCompletion(widget.lesson.id, val);
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final updatedNotes = _notes.map((n) {
        final controller = _noteControllers[n.studentId];
        return n.copyWith(
          personalNote: controller?.text.trim() ?? n.personalNote,
        );
      }).toList();

      await ref
          .read(groupLessonServiceProvider)
          .updateAttendanceAndNotes(widget.lesson.id, updatedNotes);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yoklama ve öğrenci notları güncellendi!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Grup Dersini Sil'),
        content: const Text(
          'Bu grup dersini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(groupLessonServiceProvider)
          .deleteGroupLesson(widget.lesson.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grup dersi silindi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr =
        DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(widget.lesson.dateTime);
    final attendedCount = _notes.where((n) => n.attended).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p20,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '👥 GRUP DERSİ',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.lesson.subject,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.lesson.groupName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ders Durumu & Tarih Özeti
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(AppSizes.r16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.lesson.durationMinutes} dk',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.lesson.topic,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Tamamlandı Durumu Switch'i
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_actions_rounded,
                                  color: _isCompleted
                                      ? AppColors.success
                                      : AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isCompleted
                                      ? 'Ders Tamamlandı'
                                      : 'Ders Planlandı (Bekliyor)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _isCompleted
                                        ? AppColors.success
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isCompleted,
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppColors.success,
                              onChanged: (v) => _toggleCompletion(v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Finansal Bilgi Bandı
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kişi Başı: ${AppHelpers.formatCurrency(widget.lesson.pricePerStudent)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Toplam: ${AppHelpers.formatCurrency(widget.lesson.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (widget.lesson.notes.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Grup Notu / Ödev Talimatı',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withAlpha(8),
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                      child: Text(
                        widget.lesson.notes,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Katılımcı Yoklama ve Bireysel Notlar ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Katılımcılar & Yoklama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$attendedCount / ${_notes.length} Katıldı',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: attendedCount == _notes.length
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _notes[index];
                      final controller = _noteControllers[item.studentId];

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppSizes.r16),
                          border: Border.all(
                            color: item.attended
                                ? AppColors.success.withAlpha(60)
                                : (isDark ? Colors.white10 : Colors.black12),
                            width: item.attended ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: item.attended
                                      ? AppColors.primary.withAlpha(30)
                                      : Colors.grey.withAlpha(40),
                                  child: Text(
                                    item.studentName.isNotEmpty
                                        ? item.studentName[0]
                                        : 'Ö',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.attended
                                          ? AppColors.primary
                                          : Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                // Yoklama butonu
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _notes[index] = item.copyWith(
                                        attended: !item.attended,
                                      );
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.attended
                                          ? AppColors.success.withAlpha(25)
                                          : AppColors.error.withAlpha(20),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: item.attended
                                            ? AppColors.success
                                            : AppColors.error,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          item.attended
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          size: 14,
                                          color: item.attended
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.attended ? 'Geldi' : 'Gelmedi',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: item.attended
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Bireysel Öğrenci Notu
                            TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText:
                                    '${item.studentName} için özel not/ödev durumu...',
                                hintStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Dersi Sil',
                  onPressed: _deleteLesson,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isSaving ? null : _saveChanges,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isSaving
                        ? 'Kaydediliyor...'
                        : 'Yoklama & Notları Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
