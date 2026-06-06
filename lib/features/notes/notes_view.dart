import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/note.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';

class NotesView extends ConsumerWidget {
  const NotesView({super.key});

  void _showAddNoteSheet(BuildContext context, List<Student> students) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddNoteSheet(students: students),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Ders Notlarım')),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_rounded,
                    size: 64,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    'Henüz bir not yazmadınız.',
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

          // Responsive grid layout (2 columns on mobile, beautiful spacing)
          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.p16).copyWith(bottom: 80),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteGridTile(note: note);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) =>
            Center(child: Text('Hata oluştu: ${err.toString()}')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'notes_fab',
        onPressed: () {
          final students = studentsAsync.value ?? [];
          _showAddNoteSheet(context, students);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Yeni Not'),
      ),
    );
  }
}

class NoteGridTile extends ConsumerWidget {
  final Note note;

  const NoteGridTile({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color noteBaseColor = Color(note.colorValue);
    final Color backgroundColor = isDark
        ? AppColors.surfaceDark
        : noteBaseColor.withValues(alpha: 0.08);
    final Color borderColor = isDark
        ? noteBaseColor.withValues(alpha: 0.4)
        : noteBaseColor.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.r20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.r20),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Student tag
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark
                      ? Colors.white
                      : noteBaseColor.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 4),
              if (note.studentName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: noteBaseColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Text(
                    note.studentName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : noteBaseColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // Content Body
              Expanded(
                child: Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : Colors.black87,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 6),

              // Date stamp and delete icon footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppHelpers.formatDate(note.createdAt),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Notu Sil'),
                          content: const Text(
                            'Bu notu silmek istediğinize emin misiniz?',
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
                        await ref
                            .read(databaseServiceProvider)
                            .deleteNote(note.id);
                      }
                    },
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 16,
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
}

class AddNoteSheet extends ConsumerStatefulWidget {
  final List<Student> students;

  const AddNoteSheet({super.key, required this.students});

  @override
  ConsumerState<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<AddNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Student? _selectedStudent;
  int _selectedColorValue = 0xFF4F46E5; // Default indigo
  bool _isLoading = false;

  final List<int> _colorPalette = [
    0xFF4F46E5, // Indigo
    0xFF0D9488, // Emerald Teal
    0xFFF59E0B, // Amber
    0xFFE11D48, // Rose Red
    0xFF9333EA, // Purple
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final note = Note(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      studentId: _selectedStudent?.id,
      studentName: _selectedStudent?.nickname,
      createdAt: DateTime.now(),
      colorValue: _selectedColorValue,
    );

    try {
      await ref.read(databaseServiceProvider).addNote(note);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not başarıyla kaydedildi.'),
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
                    Text('Yeni Not Oluştur', style: theme.textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Note Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Not Başlığı (Örn: Ders Hedefleri)',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (val) =>
                      AppHelpers.validateRequired(val, 'Not Başlığı'),
                ),
                const SizedBox(height: AppSizes.p16),

                // Select Student Context (Optional)
                DropdownButtonFormField<Student?>(
                  initialValue: _selectedStudent,
                  decoration: const InputDecoration(
                    hintText: 'İlgili Öğrenci (İsteğe bağlı)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: [
                    const DropdownMenuItem<Student?>(
                      value: null,
                      child: Text('Genel Not (Öğrencisiz)'),
                    ),
                    ...widget.students.map((Student student) {
                      return DropdownMenuItem<Student?>(
                        value: student,
                        child: Text(student.nickname),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedStudent = val;
                    });
                  },
                ),
                const SizedBox(height: AppSizes.p16),

                // Multi-line Content Editor
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Not detaylarını yazın...',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                  validator: (val) =>
                      AppHelpers.validateRequired(val, 'Not içeriği'),
                ),
                const SizedBox(height: AppSizes.p16),

                // Color Palette Selector
                Text(
                  'Kart Rengi Seçin',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _colorPalette.map((int colorVal) {
                    final color = Color(colorVal);
                    final isSelected = _selectedColorValue == colorVal;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorValue = colorVal;
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.p24),

                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Notu Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
