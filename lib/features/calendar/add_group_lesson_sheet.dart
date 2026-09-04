import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/group_lesson.dart';
import '../../models/student.dart';
import '../../models/teacher.dart';
import '../../services/auth_service.dart';
import '../../services/group_lesson_service.dart';

class AddGroupLessonSheet extends ConsumerStatefulWidget {
  final List<Student> students;

  const AddGroupLessonSheet({super.key, required this.students});

  static Future<void> show(BuildContext context, List<Student> students) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGroupLessonSheet(students: students),
    );
  }

  @override
  ConsumerState<AddGroupLessonSheet> createState() =>
      _AddGroupLessonSheetState();
}

class _AddGroupLessonSheetState extends ConsumerState<AddGroupLessonSheet> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _topicController = TextEditingController();
  final _pricePerStudentController = TextEditingController(text: '400');
  final _durationController = TextEditingController(text: '90');
  final _notesController = TextEditingController();

  final Set<String> _selectedStudentIds = {};
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _subject = 'Matematik';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Önceden ilk 2 öğrenciyi seçili yapabiliriz (varsa)
    if (widget.students.isNotEmpty) {
      _selectedStudentIds.add(widget.students.first.id);
      _subject = widget.students.first.subject;
      if (widget.students.length > 1) {
        _selectedStudentIds.add(widget.students[1].id);
      }
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _topicController.dispose();
    _pricePerStudentController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _currentPricePerStudent =>
      double.tryParse(_pricePerStudentController.text.trim()) ?? 0.0;
  double get _totalRevenue =>
      _currentPricePerStudent * _selectedStudentIds.length;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen grup dersine en az bir öğrenci seçin.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authServiceProvider).getCurrentUser();
      final teacherId = user?.id ?? 'mock_teacher_id';

      final selectedStudents = widget.students
          .where((s) => _selectedStudentIds.contains(s.id))
          .toList();

      final lessonDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final initialNotes = selectedStudents.map((s) {
        return GroupLessonNote(
          studentId: s.id,
          studentName: s.nickname,
          attended: true,
          personalNote: '',
        );
      }).toList();

      final groupLesson = GroupLesson(
        id: '',
        teacherId: teacherId,
        groupName: _groupNameController.text.trim(),
        subject: _subject,
        topic: _topicController.text.trim(),
        studentIds: selectedStudents.map((s) => s.id).toList(),
        studentNames: selectedStudents.map((s) => s.nickname).toList(),
        dateTime: lessonDateTime,
        durationMinutes: int.tryParse(_durationController.text.trim()) ?? 60,
        pricePerStudent: _currentPricePerStudent,
        notes: _notesController.text.trim(),
        individualNotes: initialNotes,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await ref.read(groupLessonServiceProvider).addGroupLesson(groupLesson);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${groupLesson.groupName} dersi planlandı! (${selectedStudents.length} Öğrenci)',
          ),
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authServiceProvider).getCurrentUser();
    final defaultSubject = user is Teacher && user.subject?.isNotEmpty == true
        ? user.subject!
        : 'Matematik';

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grup Dersi Planla',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Birden fazla öğrenciyle ortak ders',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
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
          const Divider(height: 1),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grup Adı
                    TextFormField(
                      controller: _groupNameController,
                      decoration: const InputDecoration(
                        labelText: 'Grup / Sınıf Adı',
                        hintText: 'Örn: 12-A AYT Matematik Grubu',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty
                              ? 'Lütfen grup adı girin.'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Konu Başlığı
                    TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'İşlenecek Konu',
                        hintText: 'Örn: Trigonometrik Denklemler Soru Çözümü',
                        prefixIcon: Icon(Icons.menu_book_rounded),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty
                              ? 'Lütfen konu başlığı girin.'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Öğrenci Çoklu Seçimi ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Derse Katılacak Öğrenciler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_selectedStudentIds.length} Seçili',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(AppSizes.r16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: widget.students.isEmpty
                          ? const Center(
                              child: Text('Kayıtlı öğrenci bulunamadı.'),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.students.map((student) {
                                final isSelected =
                                    _selectedStudentIds.contains(student.id);
                                return FilterChip(
                                  selected: isSelected,
                                  showCheckmark: true,
                                  checkmarkColor: Colors.white,
                                  selectedColor: AppColors.primary,
                                  label: Text(
                                    student.nickname,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedStudentIds.add(student.id);
                                        _subject = student.subject;
                                      } else {
                                        _selectedStudentIds.remove(student.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Tarih ve Saat Seçiciler
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(AppSizes.r12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Tarih',
                                prefixIcon:
                                    Icon(Icons.calendar_today_rounded, size: 20),
                              ),
                              child: Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            borderRadius: BorderRadius.circular(AppSizes.r12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Saat',
                                prefixIcon:
                                    Icon(Icons.access_time_rounded, size: 20),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Süre ve Kişi Başı Ücret
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Süre',
                              suffixText: 'dk',
                              prefixIcon: Icon(Icons.timer_outlined, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _pricePerStudentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Kişi Başı Ücret',
                              suffixText: 'TL',
                              prefixIcon:
                                  Icon(Icons.monetization_on_outlined, size: 20),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Toplam Kazanç Hesaplayıcı Kartı
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withAlpha(25),
                            AppColors.secondary.withAlpha(25),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Toplam Grup Dersi Geliri',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                '${_selectedStudentIds.length} Öğrenci × ${AppHelpers.formatCurrency(_currentPricePerStudent)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            AppHelpers.formatCurrency(_totalRevenue),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Genel Notlar
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Grup Notu / Ödev Talimatı (Opsiyonel)',
                        hintText:
                            'Derse getirilecek kaynaklar, testler veya ödevler...',
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action
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
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
              ),
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                _isLoading ? 'Kaydediliyor...' : 'Grup Dersini Planla',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
