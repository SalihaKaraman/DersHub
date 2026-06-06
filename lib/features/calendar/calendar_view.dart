import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/lesson.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLessonSheet(students: students),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(lessonsStreamProvider);
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
        data: (lessons) {
          if (lessons.isEmpty) {
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

          final events = <DateTime, List<Lesson>>{};
          for (final lesson in lessons) {
            final dateKey = DateTime(
              lesson.dateTime.year,
              lesson.dateTime.month,
              lesson.dateTime.day,
            );
            events.putIfAbsent(dateKey, () => []).add(lesson);
          }

          List<Lesson> getEventsForDay(DateTime day) {
            final dateKey = DateTime(day.year, day.month, day.day);
            return events[dateKey] ?? [];
          }

          final selectedDay = _selectedDay ?? _focusedDay;
          final selectedEvents = getEventsForDay(selectedDay);

          return Column(
            children: [
              TableCalendar<Lesson>(
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
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
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
                child: _buildWeeklySummary(lessons, selectedDay),
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
                          return _buildLessonTile(
                            context,
                            selectedEvents[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) =>
            Center(child: Text('Hata oluştu: ${err.toString()}')),
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

  Widget _buildWeeklySummary(List<Lesson> lessons, DateTime selectedDay) {
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
