import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/lesson.dart';
import '../../models/group_lesson.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/group_lesson_service.dart';
import '../../services/notification_service.dart';
import 'add_group_lesson_sheet.dart';
import 'group_lesson_detail_dialog.dart';

sealed class CalendarEventItem {
  DateTime get dateTime;
  bool get isCompleted;
}

class SingleLessonEvent extends CalendarEventItem {
  final Lesson lesson;
  SingleLessonEvent(this.lesson);
  @override
  DateTime get dateTime => lesson.dateTime;
  @override
  bool get isCompleted => lesson.isCompleted;
}

class GroupLessonEvent extends CalendarEventItem {
  final GroupLesson groupLesson;
  GroupLessonEvent(this.groupLesson);
  @override
  DateTime get dateTime => groupLesson.dateTime;
  @override
  bool get isCompleted => groupLesson.isCompleted;
}

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _showAddLessonSheet(BuildContext context, List<Student> students) {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ders planlamak için öncelikle bir öğrenci eklemelisiniz.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LessonTypeChoiceSheet(
        onSelectIndividual: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddLessonSheet(students: students),
          );
        },
        onSelectGroup: () {
          Navigator.pop(context);
          AddGroupLessonSheet.show(context, students);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(lessonsStreamProvider);
    final groupLessonsAsync = ref.watch(groupLessonsStreamProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Programım'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            icon: const Icon(Icons.today_outlined),
            tooltip: 'Bugün',
          ),
        ],
      ),
      body: lessonsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) =>
            Center(child: Text('Hata oluştu: ${err.toString()}')),
        data: (lessons) {
          final groupLessons = groupLessonsAsync.value ?? [];

          if (lessons.isEmpty && groupLessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 64,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    'Planlanmış ders bulunamadı.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            );
          }

          final allEvents = <CalendarEventItem>[
            ...lessons.map((l) => SingleLessonEvent(l)),
            ...groupLessons.map((gl) => GroupLessonEvent(gl)),
          ];
          allEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));

          final events = <DateTime, List<CalendarEventItem>>{};
          for (final event in allEvents) {
            final dateKey = DateTime(
              event.dateTime.year,
              event.dateTime.month,
              event.dateTime.day,
            );
            events.putIfAbsent(dateKey, () => []).add(event);
          }

          List<CalendarEventItem> getEventsForDay(DateTime day) {
            final dateKey = DateTime(day.year, day.month, day.day);
            return events[dateKey] ?? [];
          }

          final selectedDay = _selectedDay ?? _focusedDay;
          final selectedEvents = getEventsForDay(selectedDay);

          return Column(
            children: [
              TableCalendar<CalendarEventItem>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: getEventsForDay,
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onPageChanged: (focused) =>
                    setState(() => _focusedDay = focused),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: AppSizes.p12,
                ),
                child: _buildWeeklySummary(lessons, groupLessons, selectedDay),
              ),
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                        child: Text(
                          'Seçili gün için ders bulunamadı.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.p12),
                        itemCount: selectedEvents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.p12),
                        itemBuilder: (context, index) {
                          final eventItem = selectedEvents[index];
                          if (eventItem is SingleLessonEvent) {
                            return _buildLessonTile(
                              context,
                              eventItem.lesson,
                            );
                          } else if (eventItem is GroupLessonEvent) {
                            return _buildGroupLessonTile(
                              context,
                              eventItem.groupLesson,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: studentsAsync.when(
        data: (students) => FloatingActionButton.extended(
          heroTag: 'calendar_fab',
          onPressed: () => _showAddLessonSheet(context, students),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Ders Planla'),
        ),
        loading: () => const FloatingActionButton(
          heroTag: 'calendar_fab_loading',
          onPressed: null,
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (_, __) => const SizedBox(),
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, Lesson lesson) {
    final theme = Theme.of(context);
    final isPast = lesson.dateTime.isBefore(DateTime.now());

    return Card(
      color: isPast ? Colors.grey.shade100 : null,
      child: ListTile(
        onTap: () => _showLessonActions(context, lesson),
        title: Text(lesson.studentName),
        subtitle: Text(
          '${AppHelpers.formatTime(lesson.dateTime)} · ${lesson.durationMinutes} dk · ${lesson.topic}',
        ),
        trailing: Text(
          AppHelpers.formatCurrency(lesson.price),
          style: theme.textTheme.titleMedium?.copyWith(
            color: isPast ? Colors.grey : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupLessonTile(
    BuildContext context,
    GroupLesson groupLesson,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPast = groupLesson.dateTime.isBefore(DateTime.now());

    return Card(
      color: isPast ? (isDark ? Colors.white10 : Colors.grey.shade100) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(
          color: AppColors.primary.withAlpha(isDark ? 80 : 50),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: () => GroupLessonDetailDialog.show(context, groupLesson),
        borderRadius: BorderRadius.circular(AppSizes.r16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.groups_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GRUP DERSİ (${groupLesson.studentIds.length} Öğrenci)',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppHelpers.formatCurrency(groupLesson.totalPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isPast ? Colors.grey : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                groupLesson.groupName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppHelpers.formatTime(groupLesson.dateTime)} · ${groupLesson.durationMinutes} dk · ${groupLesson.topic}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Katılımcılar: ${groupLesson.studentNames.join(", ")}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLessonActions(BuildContext context, Lesson lesson) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ders Detayları',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              '${AppHelpers.formatDate(lesson.dateTime)} ${AppHelpers.formatTime(lesson.dateTime)}',
            ),
            const SizedBox(height: AppSizes.p8),
            Text('Öğrenci: ${lesson.studentName}'),
            const SizedBox(height: AppSizes.p4),
            Text('Konu: ${lesson.topic}'),
            const SizedBox(height: AppSizes.p4),
            Text('Süre: ${lesson.durationMinutes} dk'),
            const SizedBox(height: AppSizes.p16),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(databaseServiceProvider)
                    .updateLessonCompletion(lesson.id, true);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Tamamlandı İşaretle'),
            ),
            const SizedBox(height: AppSizes.p8),
            OutlinedButton(
              onPressed: () async {
                await ref.read(databaseServiceProvider).deleteLesson(lesson.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Sil'),
            ),
            const SizedBox(height: AppSizes.p8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(
    List<Lesson> lessons,
    List<GroupLesson> groupLessons,
    DateTime selectedDay,
  ) {
    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    double total = 0;
    int count = 0;

    for (final lesson in lessons) {
      if (!lesson.dateTime.isBefore(startOfWeek) &&
          !lesson.dateTime.isAfter(endOfWeek)) {
        total += lesson.price;
        count++;
      }
    }

    for (final gl in groupLessons) {
      if (!gl.dateTime.isBefore(startOfWeek) &&
          !gl.dateTime.isAfter(endOfWeek)) {
        total += gl.totalPrice;
        count++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haftalık Gelir',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                AppHelpers.formatCurrency(total),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Ders Sayısı', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSizes.p8),
              Text(
                '$count',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddLessonSheet extends ConsumerStatefulWidget {
  final List<Student> students;

  const AddLessonSheet({super.key, required this.students});

  @override
  ConsumerState<AddLessonSheet> createState() => _AddLessonSheetState();
}

class _AddLessonSheetState extends ConsumerState<AddLessonSheet> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '60');

  late Student _selectedStudent;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  bool _repeatWeekly = false;

  @override
  void initState() {
    super.initState();
    _selectedStudent = widget.students.first;
    _updateDefaultPrice();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _updateDefaultPrice() {
    final double hourlyRate = _selectedStudent.hourlyRate;
    final int minutes = int.tryParse(_durationController.text.trim()) ?? 60;
    final double calculatedPrice = hourlyRate * (minutes / 60.0);
    _priceController.text = calculatedPrice.toStringAsFixed(0);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final scheduleDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final lesson = Lesson(
      id: '',
      teacherId: ref.read(authStateProvider).value?.id ?? 't1',
      studentId: _selectedStudent.id,
      studentName: _selectedStudent.nickname,
      dateTime: scheduleDateTime,
      durationMinutes: int.tryParse(_durationController.text.trim()) ?? 60,
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      topic: _topicController.text.trim(),
      status: 'scheduled',
      notes: '',
      createdAt: DateTime.now(),
    );

    try {
      final occurrences = _repeatWeekly ? 4 : 1;
      for (var i = 0; i < occurrences; i++) {
        final scheduled = lesson.copyWith(
          id: '',
          dateTime: scheduleDateTime.add(Duration(days: 7 * i)),
        );
        await ref.read(databaseServiceProvider).addLesson(scheduled);

        final reminderTime = scheduled.dateTime.subtract(
          const Duration(minutes: 30),
        );
        unawaited(
          ref
              .read(notificationServiceProvider)
              .scheduleLessonReminder(
                dateTime: reminderTime,
                lessonTitle: _topicController.text.trim().isEmpty
                    ? 'Yeni Ders'
                    : _topicController.text.trim(),
                studentName: _selectedStudent.nickname,
              ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ders başarıyla planlandı.'),
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.r24),
          topRight: Radius.circular(AppSizes.r24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ders Planı Oluştur',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                DropdownButtonFormField<Student>(
                  initialValue: _selectedStudent,
                  decoration: const InputDecoration(labelText: 'Öğrenci Seçin'),
                  items: widget.students
                      .map(
                        (student) => DropdownMenuItem(
                          value: student,
                          child: Text(student.nickname),
                        ),
                      )
                      .toList(),
                  onChanged: (student) {
                    if (student == null) return;
                    setState(() {
                      _selectedStudent = student;
                    });
                    _updateDefaultPrice();
                  },
                ),
                const SizedBox(height: AppSizes.p16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectDate,
                        child: Text(AppHelpers.formatDate(_selectedDate)),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectTime,
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Ders Konusu',
                    hintText: 'Örneğin: Matematik tekrar',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen ders konusu girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.p16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Süre (dk)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final number = int.tryParse(value ?? '');
                          if (number == null || number <= 0) {
                            return 'Geçerli süre girin.';
                          }
                          return null;
                        },
                        onChanged: (_) => _updateDefaultPrice(),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Ücret'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final number = double.tryParse(value ?? '');
                          if (number == null || number < 0) {
                            return 'Geçerli ücret girin.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                Row(
                  children: [
                    Checkbox(
                      value: _repeatWeekly,
                      onChanged: (value) {
                        setState(() {
                          _repeatWeekly = value ?? false;
                        });
                      },
                    ),
                    const Expanded(child: Text('Haftalık olarak tekrar etsin')),
                  ],
                ),
                const SizedBox(height: AppSizes.p24),
                FilledButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonTypeChoiceSheet extends StatelessWidget {
  final VoidCallback onSelectIndividual;
  final VoidCallback onSelectGroup;

  const _LessonTypeChoiceSheet({
    required this.onSelectIndividual,
    required this.onSelectGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Ders Türü Seçin',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Planlamak istediğiniz ders formatını seçin:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          _choiceCard(
            context,
            icon: Icons.person_rounded,
            title: 'Bireysel Özel Ders',
            subtitle: 'Tek bir öğrenci ile birebir ders planlayın',
            color: AppColors.primary,
            onTap: onSelectIndividual,
          ),
          const SizedBox(height: 12),
          _choiceCard(
            context,
            icon: Icons.groups_rounded,
            title: 'Grup Dersi / Etüt',
            subtitle:
                'Birden fazla öğrenciyle ortak sınıf veya etüt dersi planlayın',
            color: AppColors.secondary,
            onTap: onSelectGroup,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _choiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(color: color.withAlpha(80), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
