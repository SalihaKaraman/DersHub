import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/lesson.dart';
import '../../models/student.dart';
import '../../services/parent_service.dart';

class ParentStudentDetailView extends ConsumerStatefulWidget {
  final Student student;
  const ParentStudentDetailView({super.key, required this.student});

  @override
  ConsumerState<ParentStudentDetailView> createState() =>
      _ParentStudentDetailViewState();
}

class _ParentStudentDetailViewState
    extends ConsumerState<ParentStudentDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lessons = ref.watch(parentStudentLessonsProvider(widget.student.id));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.student.nickname.isNotEmpty
                                  ? widget.student.nickname[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        Text(
                          widget.student.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p4),
                        Text(
                          '${widget.student.gradeLevel} · ${widget.student.subject}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Dersler'),
                Tab(text: 'İlerleme'),
                Tab(text: 'Öğretmen Notları'),
              ],
            ),
          ),
        ],
        body: lessons.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (lessonList) => TabBarView(
            controller: _tabController,
            children: [
              _LessonsTab(lessons: lessonList),
              _ProgressTab(lessons: lessonList, student: widget.student),
              _NotesTab(lessons: lessonList),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// TAB 1: Ders Takvimi (Read-Only)
// ──────────────────────────────────────────────
class _LessonsTab extends StatelessWidget {
  final List<Lesson> lessons;
  const _LessonsTab({required this.lessons});

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return _EmptyState(
        icon: Icons.calendar_today_rounded,
        title: 'Henüz ders yok',
        subtitle: 'Öğrenciye ders eklendikçe burada görünecek.',
      );
    }

    final now = DateTime.now();
    final upcoming = lessons
        .where((l) => l.dateTime.isAfter(now) && !l.isCompleted)
        .toList();
    final past = lessons
        .where((l) => l.dateTime.isBefore(now) || l.isCompleted)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(AppSizes.p16),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(title: 'Yaklaşan Dersler', count: upcoming.length),
          ...upcoming.map((l) => _LessonCard(lesson: l, isPast: false)),
          const SizedBox(height: AppSizes.p16),
        ],
        if (past.isNotEmpty) ...[
          _SectionHeader(title: 'Geçmiş Dersler', count: past.length),
          ...past.map((l) => _LessonCard(lesson: l, isPast: true)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.p8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.r8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isPast;
  const _LessonCard({required this.lesson, required this.isPast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr =
        DateFormat('d MMM y · HH:mm', 'tr_TR').format(lesson.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(
          color: isPast
              ? Colors.grey.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          if (!isPast)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPast
                  ? Colors.grey.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.r12),
            ),
            child: Icon(
              lesson.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.schedule_rounded,
              color: lesson.isCompleted ? AppColors.success : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.topic.isEmpty ? 'Ders' : lesson.topic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPast ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${lesson.durationMinutes} dk',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (lesson.isCompleted)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: const Text(
                    'Tamamlandı',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// TAB 2: İlerleme Özeti
// ──────────────────────────────────────────────
class _ProgressTab extends StatelessWidget {
  final List<Lesson> lessons;
  final Student student;
  const _ProgressTab({required this.lessons, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completed = lessons.where((l) => l.isCompleted).toList();
    final totalMinutes =
        completed.fold<int>(0, (sum, l) => sum + l.durationMinutes);
    final totalHours = (totalMinutes / 60).toStringAsFixed(1);

    // Son 4 haftalık aktivite
    final now = DateTime.now();
    final last4Weeks = List.generate(4, (i) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + 7 * (3 - i)));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final count = completed
          .where((l) =>
              l.dateTime.isAfter(weekStart) && l.dateTime.isBefore(weekEnd))
          .length;
      return count;
    });

    return ListView(
      padding: const EdgeInsets.all(AppSizes.p16),
      children: [
        // İstatistik kartları
        Row(
          children: [
            Expanded(
                child: _StatCard(
              icon: Icons.school_rounded,
              label: 'Toplam Ders',
              value: '${completed.length}',
              color: AppColors.primary,
            )),
            const SizedBox(width: AppSizes.p12),
            Expanded(
                child: _StatCard(
              icon: Icons.timer_rounded,
              label: 'Toplam Saat',
              value: '$totalHours s',
              color: AppColors.secondary,
            )),
          ],
        ),
        const SizedBox(height: AppSizes.p16),
        Row(
          children: [
            Expanded(
                child: _StatCard(
              icon: Icons.trending_up_rounded,
              label: 'Bu Ayki Ders',
              value: '${completed.where((l) => l.dateTime.month == now.month).length}',
              color: AppColors.accent,
            )),
            const SizedBox(width: AppSizes.p12),
            Expanded(
                child: _StatCard(
              icon: Icons.attach_money_rounded,
              label: 'Saatlik Ücret',
              value: '₺${student.hourlyRate.toStringAsFixed(0)}',
              color: AppColors.error,
            )),
          ],
        ),
        const SizedBox(height: AppSizes.p24),

        // Son 4 hafta grafiği (basit bar)
        Container(
          padding: const EdgeInsets.all(AppSizes.p20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.r20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Son 4 Hafta',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p16),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(4, (i) {
                    final maxVal =
                        last4Weeks.reduce((a, b) => a > b ? a : b);
                    final ratio =
                        maxVal == 0 ? 0.0 : last4Weeks[i] / maxVal;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${last4Weeks[i]}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 36,
                          height: 80 * ratio + 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF8D73FF)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${i + 1}.H',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondaryLight),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.p8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.r12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSizes.p12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// TAB 3: Öğretmen Notları
// ──────────────────────────────────────────────
class _NotesTab extends StatelessWidget {
  final List<Lesson> lessons;
  const _NotesTab({required this.lessons});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lessonsWithNotes =
        lessons.where((l) => l.notes.isNotEmpty && l.isCompleted).toList();

    if (lessonsWithNotes.isEmpty) {
      return _EmptyState(
        icon: Icons.notes_rounded,
        title: 'Henüz not yok',
        subtitle: 'Öğretmen ders tamamlandığında not eklediğinde burada görünür.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: lessonsWithNotes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p12),
      itemBuilder: (context, i) {
        final lesson = lessonsWithNotes[i];
        final dateStr =
            DateFormat('d MMMM y', 'tr_TR').format(lesson.dateTime);
        return Container(
          padding: const EdgeInsets.all(AppSizes.p16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.r16),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: AppColors.secondary, size: 18),
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: Text(
                      lesson.topic.isEmpty ? 'Ders Notu' : lesson.topic,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p12),
              Container(
                padding: const EdgeInsets.all(AppSizes.p12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                child: Text(
                  lesson.notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// Ortak boş durum widget'ı
// ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
