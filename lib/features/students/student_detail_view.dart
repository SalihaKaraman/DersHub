import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/student.dart';
import '../../models/lesson.dart';
import '../../models/note.dart';
import '../../models/group_lesson.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/exam.dart';
import '../../services/exam_service.dart';
import '../../services/group_lesson_service.dart';
import '../calendar/group_lesson_detail_dialog.dart';
import '../reports/reports_list_view.dart';
import '../../services/messaging_service.dart';

class StudentDetailView extends ConsumerStatefulWidget {
  final Student student;

  const StudentDetailView({super.key, required this.student});

  @override
  ConsumerState<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends ConsumerState<StudentDetailView> {
  String _editingNickname = '';

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _saveNickname() async {
    final newNick = _editingNickname.trim();
    if (newNick.isEmpty) return;
    final updated = widget.student.copyWith(nickname: newNick);
    await ref.read(databaseServiceProvider).updateStudent(updated);
  }

  Future<void> _toggleActive(bool val) async {
    final updated = widget.student.copyWith(isActive: val);
    await ref.read(databaseServiceProvider).updateStudent(updated);
  }

  Future<void> _editHourlyRate() async {
    if (!widget.student.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sadece aktif öğrencilerin ücreti değiştirilebilir.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final controller =
        TextEditingController(text: widget.student.hourlyRate.toString());
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saatlik Ücreti Düzenle'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'TL'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (res == true) {
      final newRate = double.tryParse(controller.text.trim());
      if (newRate != null) {
        final updated = widget.student.copyWith(hourlyRate: newRate);
        await ref.read(databaseServiceProvider).updateStudent(updated);
      }
    }
  }

  Future<void> _addLesson() async {
    final topicController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ders Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(hintText: 'Konu'),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Süre (dk)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final topic = topicController.text.trim();
    final duration = int.tryParse(durationController.text.trim()) ?? 60;
    final lesson = Lesson(
      id: '',
      teacherId: ref.read(authStateProvider).value?.id ?? 't1',
      studentId: widget.student.id,
      studentName: widget.student.nickname,
      dateTime: DateTime.now(),
      durationMinutes: duration,
      price: 0.0,
      topic: topic,
      status: 'scheduled',
      notes: '',
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await ref.read(databaseServiceProvider).addLesson(lesson);
  }

  Future<void> _showNoteDialog({Note? noteToEdit}) async {
    final isEditing = noteToEdit != null;
    final titleController =
        TextEditingController(text: noteToEdit?.title ?? '');
    final contentController =
        TextEditingController(text: noteToEdit?.content ?? '');
    int selectedColor = noteToEdit?.colorValue ?? 0xFF4F46E5;

    final List<int> colorPalette = [
      0xFF4F46E5, // Indigo
      0xFF0D9488, // Emerald Teal
      0xFFF59E0B, // Amber
      0xFFE11D48, // Rose Red
      0xFF9333EA, // Purple
    ];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r20),
            ),
            title: Text(isEditing ? 'Notu Düzenle' : 'Yeni Not Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      hintText: 'Not başlığı girin...',
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'İçerik',
                      hintText: 'Not içeriğini girin...',
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  const Text(
                    'Renk Seçin',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: colorPalette.map((colorVal) {
                      final isSelected = selectedColor == colorVal;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = colorVal;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colorVal),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty &&
                      contentController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: Text(isEditing ? 'Kaydet' : 'Ekle'),
              ),
            ],
          );
        },
      ),
    );

    if (result != true) return;

    if (isEditing) {
      final updatedNote = noteToEdit.copyWith(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        colorValue: selectedColor,
      );
      await ref.read(databaseServiceProvider).updateNote(updatedNote);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not başarıyla güncellendi.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      final note = Note(
        id: '',
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        studentId: widget.student.id,
        studentName: widget.student.nickname,
        createdAt: DateTime.now(),
        colorValue: selectedColor,
      );
      await ref.read(databaseServiceProvider).addNote(note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not başarıyla eklendi.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notu Sil'),
        content: Text(
          note.title.isNotEmpty
              ? '"${note.title}" başlıklı not silinecek. Onaylıyor musunuz?'
              : 'Bu not silinecek. Onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sil',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(databaseServiceProvider).deleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not silindi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showMessageDialog() async {
    final messageController = TextEditingController();
    String? phone = widget.student.phoneNumber;

    if (phone == null || phone.isEmpty) {
      final phoneController = TextEditingController();
      final phoneRes = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Telefon Numarası Eksik'),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+90 555 123 45 67'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      );

      if (phoneRes == true && phoneController.text.trim().isNotEmpty) {
        phone = phoneController.text.trim();
        final updated = widget.student.copyWith(phoneNumber: phone);
        await ref.read(databaseServiceProvider).updateStudent(updated);
      } else {
        return;
      }
    }

    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesaj Gönder'),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Mesajınız...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'sms'),
            child: const Text('SMS Uygulaması (Cihaz)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'wa'),
            child: const Text('WhatsApp (Cihaz)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'twilio_wa'),
            child: const Text('Twilio WhatsApp',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (result == null || messageController.text.trim().isEmpty) return;

    final msg = messageController.text.trim();
    final messaging = ref.read(messagingServiceProvider);

    if (result == 'wa') {
      await messaging.launchWhatsAppApp(to: phone, message: msg);
    } else if (result == 'sms') {
      await messaging.launchSmsApp(to: phone, message: msg);
    } else if (result == 'twilio_wa') {
      final success =
          await messaging.sendWhatsAppViaTwilio(to: phone, message: msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(success ? 'Mesaj gönderildi!' : 'Mesaj gönderilemedi.'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showExamDetail(Exam exam) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exam.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ders: ${exam.subject}'),
            Text('Tür: ${exam.type}'),
            Text('Tarih: ${_formatDate(exam.date)}'),
            Text(
              exam.score == null
                  ? 'Not: Girilmedi'
                  : 'Not: ${exam.score}/${exam.maxScore}',
            ),
            if (exam.notes?.isNotEmpty == true) ...[
              const SizedBox(height: AppSizes.p12),
              Text(exam.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _addExam() async {
    final titleController = TextEditingController();
    final scoreController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Sınav Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  hintText: 'Sınav Başlığı (Örn: 1. Yazılı)'),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: 'Alınan Not (İsteğe Bağlı)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      final scoreStr = scoreController.text.trim();
      final score = scoreStr.isNotEmpty ? double.tryParse(scoreStr) : null;

      final exam = Exam(
        id: '',
        studentId: widget.student.id,
        title: titleController.text.trim(),
        subject: widget.student.subject,
        date: DateTime.now(),
        score: score,
        createdAt: DateTime.now(),
      );

      await ref.read(examServiceProvider).addExam(exam);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
        widget.student.isActive ? AppColors.success : AppColors.warning;

    final lessonsAsync = ref.watch(lessonsStreamProvider);
    final groupLessonsAsync =
        ref.watch(studentGroupLessonsStreamProvider(widget.student.id));
    final paymentsAsync = ref.watch(paymentsStreamProvider);
    final notesAsync = ref.watch(notesStreamProvider);
    final examsAsync = ref.watch(studentExamsStreamProvider(widget.student.id));

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.student.nickname),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Genel'),
              Tab(text: 'Dersler'),
              Tab(text: 'Sınavlar'),
              Tab(text: 'Ödemeler'),
              Tab(text: 'Notlar'),
              Tab(text: 'Raporlar & Sertifikalar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Genel Bilgiler
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSizes.r24),
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'student-${widget.student.id}',
                          child: _buildAvatar(),
                        ),
                        const SizedBox(width: AppSizes.p16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.student.nickname,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      _editingNickname =
                                          widget.student.nickname;
                                      final res = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Rumuzu Düzenle'),
                                          content: TextField(
                                            autofocus: true,
                                            onChanged: (v) =>
                                                _editingNickname = v,
                                            controller: TextEditingController(
                                              text: _editingNickname,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Kaydet'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (res == true) {
                                        await _saveNickname();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _showMessageDialog,
                                    icon: const Icon(
                                      Icons.message,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Text(
                                '${widget.student.gradeLevel} · ${widget.student.subject}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      widget.student.isActive
                                          ? 'Aktif'
                                          : 'Pasif',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.p12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${AppHelpers.formatCurrency(widget.student.hourlyRate)}/saat',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.p12),
                              Row(
                                children: [
                                  const Text(
                                    'Öğrenci Durumu:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.p12),
                                  Switch(
                                    value: widget.student.isActive,
                                    onChanged: (v) => _toggleActive(v),
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: AppColors.success,
                                    inactiveThumbColor: Colors.grey.shade400,
                                    inactiveTrackColor: Colors.white24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.school_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Kayıt Tarihi'),
                      subtitle: Text(_formatDate(widget.student.createdAt)),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.payments_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Saatlik Ücret'),
                      subtitle: Text(
                        AppHelpers.formatCurrency(widget.student.hourlyRate),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: _editHourlyRate,
                        tooltip: 'Ücreti Düzenle',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Ders Geçmişi (Bireysel + Grup Dersleri)
            lessonsAsync.when(
              data: (lessons) {
                final studentLessons = lessons
                    .where((l) => (l).studentId == widget.student.id)
                    .toList();
                final studentGroupLessons = groupLessonsAsync.value ?? [];

                final allStudentLessons = <dynamic>[
                  ...studentLessons,
                  ...studentGroupLessons,
                ];
                allStudentLessons.sort((a, b) {
                  final DateTime aDate =
                      a is Lesson ? a.dateTime : (a as GroupLesson).dateTime;
                  final DateTime bDate =
                      b is Lesson ? b.dateTime : (b as GroupLesson).dateTime;
                  return bDate.compareTo(aDate);
                });

                return Stack(
                  children: [
                    allStudentLessons.isEmpty
                        ? const Center(child: Text('Henüz ders yok.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSizes.p16,
                              AppSizes.p16,
                              AppSizes.p16,
                              80,
                            ),
                            itemCount: allStudentLessons.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSizes.p12),
                            itemBuilder: (context, i) {
                              final item = allStudentLessons[i];
                              if (item is GroupLesson) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.r16,
                                    ),
                                    side: BorderSide(
                                      color: AppColors.primary.withAlpha(50),
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () => GroupLessonDetailDialog.show(
                                        context, item),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          AppColors.primary.withAlpha(25),
                                      child: const Icon(
                                        Icons.groups_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.topic,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.primary.withAlpha(25),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'GRUP',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      '${_formatDate(item.dateTime)} · ${item.durationMinutes} dk · ${item.groupName}',
                                    ),
                                    trailing: Icon(
                                      item.isCompleted
                                          ? Icons.check_circle
                                          : Icons.schedule,
                                      color: item.isCompleted
                                          ? AppColors.success
                                          : AppColors.textSecondaryDark,
                                    ),
                                  ),
                                );
                              }

                              final Lesson lesson = item as Lesson;
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r16,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(lesson.topic),
                                  subtitle: Text(
                                    '${_formatDate(lesson.dateTime)} · ${lesson.durationMinutes} dk',
                                  ),
                                  trailing: Icon(
                                    lesson.isCompleted
                                        ? Icons.check_circle
                                        : Icons.schedule,
                                    color: lesson.isCompleted
                                        ? AppColors.success
                                        : AppColors.textSecondaryDark,
                                  ),
                                ),
                              );
                            },
                          ),
                    Positioned(
                      bottom: AppSizes.p16,
                      right: AppSizes.p16,
                      child: FloatingActionButton.extended(
                        heroTag: 'fab-lesson-${widget.student.id}',
                        onPressed: _addLesson,
                        label: const Text('Yeni Ders Ekle'),
                        icon: const Icon(Icons.add),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, st) => Center(
                child: Text('Dersler yüklenirken hata: ${e.toString()}'),
              ),
            ),

            // Sınavlar
            examsAsync.when(
              data: (exams) {
                final gradedExams = exams.where((e) => e.score != null).toList()
                  ..sort((a, b) => a.date.compareTo(b.date));

                return Stack(
                  children: [
                    exams.isEmpty
                        ? const Center(child: Text('Henüz sınav eklenmemiş.'))
                        : Column(
                            children: [
                              if (gradedExams.length > 1)
                                Container(
                                  height: 200,
                                  padding: const EdgeInsets.only(
                                      top: AppSizes.p24, right: AppSizes.p24),
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData:
                                          const FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: gradedExams
                                              .asMap()
                                              .entries
                                              .map((e) {
                                            return FlSpot(e.key.toDouble(),
                                                e.value.score!);
                                          }).toList(),
                                          isCurved: true,
                                          color: AppColors.primary,
                                          barWidth: 4,
                                          dotData: const FlDotData(show: true),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSizes.p16,
                                    AppSizes.p16,
                                    AppSizes.p16,
                                    80,
                                  ),
                                  itemCount: exams.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppSizes.p12),
                                  itemBuilder: (context, i) {
                                    final exam = exams[i];
                                    return Card(
                                      child: ListTile(
                                        title: Text(exam.title),
                                        subtitle: Text(
                                            '${_formatDate(exam.date)} · ${exam.type}'),
                                        trailing: exam.score != null
                                            ? Text(
                                                '${exam.score}/${exam.maxScore}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : const Text('Not girilmedi'),
                                        onTap: () => _showExamDetail(exam),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                    Positioned(
                      bottom: AppSizes.p16,
                      right: AppSizes.p16,
                      child: FloatingActionButton.extended(
                        heroTag: 'fab-exam-${widget.student.id}',
                        onPressed: _addExam,
                        label: const Text('Yeni Sınav'),
                        icon: const Icon(Icons.add),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, st) => Center(
                child: Text('Sınavlar yüklenirken hata: ${e.toString()}'),
              ),
            ),

            // Ödemeler
            paymentsAsync.when(
              data: (payments) {
                final items = payments
                    .where((p) => (p as dynamic).studentId == widget.student.id)
                    .toList();
                double total = 0;
                double pending = 0;
                for (final p in items) {
                  try {
                    final amt = (p as dynamic).amount as num;
                    total += amt.toDouble();
                    final status = (p as dynamic).status ?? 'paid';
                    if (status != 'paid') pending += amt.toDouble();
                  } catch (_) {}
                }

                return Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r20),
                        ),
                        child: ListTile(
                          title: const Text('Toplam Kazanç'),
                          subtitle: Text(AppHelpers.formatCurrency(total)),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r20),
                        ),
                        child: ListTile(
                          title: const Text('Bekleyen Ödeme'),
                          subtitle: Text(AppHelpers.formatCurrency(pending)),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Expanded(
                        child: items.isEmpty
                            ? Center(child: Text('Ödeme kaydı yok.'))
                            : ListView.separated(
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSizes.p12),
                                itemBuilder: (context, i) {
                                  final p = items[i] as dynamic;
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        AppHelpers.formatCurrency(
                                          (p.amount as num).toDouble(),
                                        ),
                                      ),
                                      subtitle: Text(p.status ?? ''),
                                      trailing: Text(
                                        p.paymentDate != null
                                            ? _formatDate(
                                                (p.paymentDate as DateTime),
                                              )
                                            : '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Ödeme Al'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, st) => Center(
                child: Text('Ödemeler yüklenirken hata: ${e.toString()}'),
              ),
            ),

            // Notlar
            notesAsync.when(
              data: (notes) {
                final items = notes
                    .where((n) => (n).studentId == widget.student.id)
                    .toList();
                return Stack(
                  children: [
                    items.isEmpty
                        ? const Center(child: Text('Henüz not yok.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSizes.p16,
                              AppSizes.p16,
                              AppSizes.p16,
                              80,
                            ),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSizes.p12),
                            itemBuilder: (context, i) {
                              final Note note = items[i];
                              return Card(
                                color: Color(note.colorValue),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.r16),
                                ),
                                child: ListTile(
                                  onTap: () =>
                                      _showNoteDialog(noteToEdit: note),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.p16,
                                    vertical: AppSizes.p8,
                                  ),
                                  title: Text(
                                    note.title.isNotEmpty
                                        ? note.title
                                        : 'Başlıksız Not',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (note.content.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          note.content,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 13,
                                            color: Colors.white60,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(note.createdAt),
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        tooltip: 'Düzenle',
                                        onPressed: () => _showNoteDialog(
                                          noteToEdit: note,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        tooltip: 'Sil',
                                        onPressed: () => _deleteNote(note),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    Positioned(
                      bottom: AppSizes.p16,
                      right: AppSizes.p16,
                      child: FloatingActionButton.extended(
                        heroTag: 'fab-note-${widget.student.id}',
                        onPressed: () => _showNoteDialog(),
                        label: const Text('Yeni Not Ekle'),
                        icon: const Icon(Icons.note_add_rounded),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, st) => Center(
                child: Text('Notlar yüklenirken hata: ${e.toString()}'),
              ),
            ),

            // 5. Raporlar & Sertifikalar
            lessonsAsync.when(
              data: (allLessons) {
                final studentLessons = allLessons
                    .where((l) => l.studentId == widget.student.id)
                    .toList();
                return ReportsListView(
                  student: widget.student,
                  lessons: studentLessons,
                  isTeacher: true,
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) =>
                  Center(child: Text('Ders bilgisi alınamadı: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.student.nickname.isNotEmpty ? widget.student.nickname[0] : 'Ö',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
    );
  }
}
