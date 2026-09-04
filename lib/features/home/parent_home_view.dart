import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/app_user.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';
import '../../services/parent_service.dart';
import '../parent/parent_student_detail_view.dart';

class ParentHomeView extends ConsumerStatefulWidget {
  const ParentHomeView({super.key});

  @override
  ConsumerState<ParentHomeView> createState() => _ParentHomeViewState();
}

class _ParentHomeViewState extends ConsumerState<ParentHomeView>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _greetingAnimController;
  

  @override
  void initState() {
    super.initState();
    _greetingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // _greetingFade =
        CurvedAnimation(parent: _greetingAnimController, curve: Curves.easeIn);
    _greetingAnimController.forward();
  }

  @override
  void dispose() {
    _greetingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    final pages = [
      _StudentsPage(user: user),
      _ProfilePage(user: user),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SAYFA 1: Öğrencilerim
// ──────────────────────────────────────────────
class _StudentsPage extends ConsumerWidget {
  final AppUser? user;
  const _StudentsPage({required this.user});

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın 🌤';
    if (hour < 18) return 'İyi Günler ☀️';
    return 'İyi Akşamlar 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentsStream = ref.watch(parentStudentsStreamProvider);

    return CustomScrollView(
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSizes.p20,
              left: AppSizes.p24,
              right: AppSizes.p24,
              bottom: AppSizes.p24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greetingText(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.fullName ?? 'Veli',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Çıkış Butonu
                    Consumer(builder: (ctx, r, _) {
                      return GestureDetector(
                        onTap: () => r.read(authServiceProvider).signOut(),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.p8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 20),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: AppSizes.p20),
                // Özet istatistik bandı
                studentsStream.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (students) => _SummaryBand(students: students),
                ),
              ],
            ),
          ),
        ),

        // ── Öğrenciler Başlığı ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.p24, AppSizes.p24, AppSizes.p24, AppSizes.p8),
            child: Text(
              'Çocuklarım',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // ── Öğrenci Listesi ──
        studentsStream.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(child: Text('Hata: $e')),
          ),
          data: (students) {
            if (students.isEmpty) {
              return SliverFillRemaining(
                child: _EmptyStudentsState(),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _StudentCard(student: students[i]),
                childCount: students.length,
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _SummaryBand extends ConsumerWidget {
  final List<Student> students;
  const _SummaryBand({required this.students});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Basit özet (geliştirilebilir: her öğrenci için stream birleştirme)
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BandItem(
              label: 'Öğrenci',
              value: '${students.length}',
              icon: Icons.people_rounded),
          Container(
              width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3)),
          _BandItem(
              label: 'Aktif',
              value: '${students.where((s) => s.isActive).length}',
              icon: Icons.check_circle_rounded),
          Container(
              width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3)),
          _BandItem(
              label: 'Branş',
              value: students.isNotEmpty
                  ? students.map((s) => s.subject).toSet().length.toString()
                  : '0',
              icon: Icons.school_rounded),
        ],
      ),
    );
  }
}

class _BandItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _BandItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _StudentCard extends ConsumerWidget {
  final Student student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lessonsAsync =
        ref.watch(parentStudentLessonsProvider(student.id));

    final upcomingCount = lessonsAsync.when(
      data: (lessons) => lessons
          .where((l) =>
              l.dateTime.isAfter(DateTime.now()) && !l.isCompleted)
          .length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final lastLesson = lessonsAsync.when(
      data: (lessons) {
        final completed =
            lessons.where((l) => l.isCompleted).toList();
        if (completed.isEmpty) return null;
        completed.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return completed.first;
      },
      loading: () => null,
      error: (_, __) => null,
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ParentStudentDetailView(student: student)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.p16, vertical: AppSizes.p8),
        padding: const EdgeInsets.all(AppSizes.p16),
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
        child: Row(
          children: [
            // Avatar
            Hero(
              tag: 'student_avatar_${student.id}',
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF8D73FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.nickname.isNotEmpty
                        ? student.nickname[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p16),
            // Bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.nickname,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student.gradeLevel} · ${student.subject}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  if (lastLesson != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Son ders: ${DateFormat('d MMM', 'tr_TR').format(lastLesson.dateTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
            // Sağ badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (upcomingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    child: Text(
                      '$upcomingCount ders',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: student.isActive
                        ? AppColors.success
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSizes.p8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}

class _EmptyStudentsState extends StatelessWidget {
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEDE7FF),
                    Color(0xFFD6C6FF),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care_rounded,
                  color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: AppSizes.p24),
            Text(
              'Henüz bağlı öğrenci yok',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              'Öğretmeninizden sizi öğrencinizin hesabına bağlamasını isteyin.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SAYFA 2: Profil
// ──────────────────────────────────────────────
class _ProfilePage extends ConsumerWidget {
  final AppUser? user;
  const _ProfilePage({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.p16),
            // Avatar
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user?.fullName.isNotEmpty == true
                      ? user!.fullName[0].toUpperCase()
                      : 'V',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              user?.fullName ?? 'Veli',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: AppSizes.p12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16, vertical: AppSizes.p8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.r20),
              ),
              child: const Text(
                '👨‍👩‍👧 Veli Hesabı',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(height: AppSizes.p32),
            // Çıkış yap
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Çıkış Yap'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// BOTTOM NAV
// ──────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            _NavItem(
              icon: Icons.people_alt_rounded,
              label: 'Öğrencilerim',
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
