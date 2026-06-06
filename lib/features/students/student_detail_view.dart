import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/student.dart';
import '../../models/lesson.dart';
import '../../models/note.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

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

  Future<void> _addNote() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Not Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Başlık'),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(hintText: 'İçerik'),
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

    final note = Note(
      id: '',
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      studentId: widget.student.id,
      studentName: widget.student.nickname,
      createdAt: DateTime.now(),
    );

    await ref.read(databaseServiceProvider).addNote(note);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = widget.student.isActive
        ? AppColors.success
        : AppColors.warning;

    final lessonsAsync = ref.watch(lessonsStreamProvider);
    final paymentsAsync = ref.watch(paymentsStreamProvider);
    final notesAsync = ref.watch(notesStreamProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.student.nickname),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Genel'),
              Tab(text: 'Dersler'),
              Tab(text: 'Ödemeler'),
              Tab(text: 'Notlar'),
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
                                  Chip(
                                    label: Text(
                                      widget.student.isActive
                                          ? 'Aktif'
                                          : 'Pasif',
                                    ),
                                    backgroundColor: statusColor.withValues(
                                      alpha: 0.16,
                                    ),
                                    labelStyle: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.p12),
                                  Chip(
                                    label: Text(
                                      '${AppHelpers.formatCurrency(widget.student.hourlyRate)}/saat',
                                    ),
                                    backgroundColor: Colors.white24,
                                    labelStyle: TextStyle(
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.p12),
                              Row(
                                children: [
                                  const Text('Durum:'),
                                  const SizedBox(width: AppSizes.p8),
                                  Switch(
                                    value: widget.student.isActive,
                                    onChanged: (v) => _toggleActive(v),
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
                    ),
                  ),
                ],
              ),
            ),

            // Ders Geçmişi
            lessonsAsync.when(
              data: (lessons) {
                final items = lessons
                    .where((l) => (l).studentId == widget.student.id)
                    .toList();
                return Stack(
                  children: [
                    items.isEmpty
                        ? const Center(child: Text('Henüz ders yok.'))
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
                              final Lesson lesson = items[i];
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
                                child: ListTile(
                                  title: Text(
                                    note.title,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    note.content,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Text(
                                    _formatDate(note.createdAt),
                                    style: const TextStyle(color: Colors.white70),
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
                        onPressed: _addNote,
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
