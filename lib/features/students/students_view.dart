import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'student_detail_view.dart';

class StudentsView extends ConsumerStatefulWidget {
  const StudentsView({super.key});

  @override
  ConsumerState<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends ConsumerState<StudentsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showActiveOnly = true;
  String _selectedGrade = 'Tümü';

  final List<String> _gradeOptions = [
    'Tümü',
    '12. Sınıf',
    '11. Sınıf',
    '10. Sınıf',
    '9. Sınıf',
    '8. Sınıf',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStudentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddStudentSheet(),
    );
  }

  Future<bool> _confirmDelete(Student student) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Öğrenciyi Sil'),
            content: Text(
              '${student.nickname} isimli öğrenciyi silmek istediğinize emin misiniz?',
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
        ) ??
        false;
  }

  Future<void> _deleteStudent(Student student) async {
    final shouldDelete = await _confirmDelete(student);
    if (!shouldDelete) return;

    try {
      await ref.read(databaseServiceProvider).deleteStudent(student.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.nickname} başarıyla silindi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci silinirken hata oluştu: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrencilerim'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p12,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Öğrenci, branş veya sınıf ara...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: AppSizes.p16),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Sadece Aktif'),
                        selected: _showActiveOnly,
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.18,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _showActiveOnly = selected;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedGrade,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.filter_alt_outlined),
                          hintText: 'Sınıf',
                        ),
                        items: _gradeOptions
                            .map(
                              (grade) => DropdownMenuItem<String>(
                                value: grade,
                                child: Text(grade),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedGrade = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                final activeCount = students
                    .where((student) => student.isActive)
                    .length;
                final filteredStudents = students.where((student) {
                  final matchesQuery =
                      _searchQuery.isEmpty ||
                      student.nickname.toLowerCase().contains(_searchQuery) ||
                      student.subject.toLowerCase().contains(_searchQuery) ||
                      student.gradeLevel.toLowerCase().contains(_searchQuery);
                  final matchesActive = !_showActiveOnly || student.isActive;
                  final matchesGrade =
                      _selectedGrade == 'Tümü' ||
                      student.gradeLevel == _selectedGrade;
                  return matchesQuery && matchesActive && matchesGrade;
                }).toList();

                if (filteredStudents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 72,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: AppSizes.p20),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Bu filtre ve arama ile eşleşen öğrenci bulunamadı.'
                                : 'Henüz öğrenci eklemediniz. Yeni bir öğrenci ekleyerek listeyi doldurun.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p8,
                  ),
                  itemCount: filteredStudents.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.p12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.p8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryChip(
                              context,
                              label: 'Toplam',
                              value: students.length.toString(),
                              icon: Icons.group,
                            ),
                            const SizedBox(width: AppSizes.p12),
                            _buildSummaryChip(
                              context,
                              label: 'Aktif',
                              value: activeCount.toString(),
                              icon: Icons.check_circle,
                            ),
                          ],
                        ),
                      );
                    }

                    final student = filteredStudents[index - 1];
                    return Dismissible(
                      key: ValueKey(student.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppSizes.r20),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSizes.p20),
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        await _deleteStudent(student);
                        return false;
                      },
                      child: StudentCard(
                        student: student,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StudentDetailView(student: student),
                            ),
                          );
                        },
                        onDelete: () => _deleteStudent(student),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) =>
                  Center(child: Text('Hata oluştu: ${err.toString()}')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'students_fab',
        onPressed: () => _showAddStudentSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Yeni Öğrenci'),
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p16,
          horizontal: AppSizes.p16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.r20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: AppSizes.p8),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.14),
              AppColors.secondary.withValues(alpha: 0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.r24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            Hero(
              tag: 'student-${student.id}',
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    student.nickname.isNotEmpty ? student.nickname[0] : 'Ö',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.nickname,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    '${student.gradeLevel} · ${student.subject}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Row(
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p12,
                        ),
                        label: Text(student.isActive ? 'Aktif' : 'Pasif'),
                        backgroundColor: student.isActive
                            ? AppColors.success.withValues(alpha: 0.16)
                            : AppColors.warning.withValues(alpha: 0.16),
                        labelStyle: TextStyle(
                          color: student.isActive
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Text(
                        AppHelpers.formatCurrency(student.hourlyRate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondaryDark,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Öğrenciyi Sil'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddStudentSheet extends ConsumerStatefulWidget {
  const AddStudentSheet({super.key});

  @override
  ConsumerState<AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends ConsumerState<AddStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _rateController = TextEditingController();
  String _selectedGrade = '12. Sınıf';
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final teacherId = ref.read(authStateProvider).value?.id ?? 'mock_teacher';
    final newStudent = Student(
      id: '',
      teacherId: teacherId,
      nickname: _nicknameController.text.trim(),
      gradeLevel: _selectedGrade,
      subject: _subjectController.text.trim(),
      hourlyRate: double.tryParse(_rateController.text.trim()) ?? 0.0,
      createdAt: DateTime.now(),
      isActive: true,
    );

    try {
      await ref.read(databaseServiceProvider).addStudent(newStudent);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci başarıyla eklendi.'),
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
  void dispose() {
    _nicknameController.dispose();
    _subjectController.dispose();
    _rateController.dispose();
    super.dispose();
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
                      'Yeni Öğrenci Ekle',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: 'Öğrenci Adı Soyadı',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) =>
                      AppHelpers.validateRequired(val, 'Öğrenci Adı'),
                ),
                const SizedBox(height: AppSizes.p16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGrade,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_outlined),
                    hintText: 'Sınıf Düzeyi',
                  ),
                  items:
                      [
                        '12. Sınıf',
                        '11. Sınıf',
                        '10. Sınıf',
                        '9. Sınıf',
                        '8. Sınıf',
                      ].map((grade) {
                        return DropdownMenuItem<String>(
                          value: grade,
                          child: Text(grade),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedGrade = value;
                    });
                  },
                  validator: (value) =>
                      AppHelpers.validateRequired(value, 'Sınıf Düzeyi'),
                ),
                const SizedBox(height: AppSizes.p16),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    hintText: 'Ders / Branş (Örn: Matematik)',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  validator: (val) =>
                      AppHelpers.validateRequired(val, 'Ders / Branş'),
                ),
                const SizedBox(height: AppSizes.p16),
                TextFormField(
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Saatlik Ders Ücreti (TL)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (val) =>
                      AppHelpers.validateRequired(val, 'Saatlik Ders Ücreti'),
                ),
                const SizedBox(height: AppSizes.p24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
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
