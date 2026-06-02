import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/lesson.dart';
import '../../models/payment.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/settings_service.dart';
import '../../services/notification_service.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final studentsStream = ref.watch(studentsStreamProvider);
    final lessonsStream = ref.watch(lessonsStreamProvider);
    final paymentsStream = ref.watch(paymentsStreamProvider);

    final studentCount = studentsStream.when(
      data: (students) => students.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    final lessonCount = lessonsStream.when(
      data: (lessons) => lessons.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    final totalEarnings = paymentsStream.when(
      data: (payments) => payments
          .where((payment) => payment.status == 'paid')
          .fold<double>(0.0, (sum, payment) => sum + payment.amount.toDouble()),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    Future<void> copyCsvData(
      BuildContext context,
      List<Student> students,
      List<Lesson> lessons,
      List<Payment> payments,
    ) async {
      final buffer = StringBuffer();
      buffer.writeln('Type,Id,Name,Extra,Amount,DueDate');
      for (final student in students) {
        buffer.writeln(
          'Student,${student.id},${student.nickname},${student.subject},,${student.createdAt.toIso8601String()}',
        );
      }
      for (final lesson in lessons) {
        buffer.writeln(
          'Lesson,${lesson.id},${lesson.studentName},,${lesson.price},${lesson.dateTime.toIso8601String()}',
        );
      }
      for (final payment in payments) {
        buffer.writeln(
          'Payment,${payment.id},${payment.studentName},${payment.status},${payment.amount},${payment.dueDate.toIso8601String()}',
        );
      }

      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV verileri panoya kopyalandı.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    return authState.when(
      data: (teacher) {
        final displayName = teacher?.fullName ?? 'DersHub Öğretmeni';
        final displaySubject = teacher?.subject ?? 'Genel Ders';
        final email = teacher?.email ?? 'email@ornek.com';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSizes.r24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0] : 'D',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
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
                                    displayName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.p4),
                                  Text(
                                    displaySubject,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p24),
                        Text(
                          'Profil Özeti',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        Row(
                          children: [
                            _buildStatTile(
                              label: 'Öğrenci',
                              value: studentCount.toString(),
                              icon: Icons.people_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: AppSizes.p12),
                            _buildStatTile(
                              label: 'Ders',
                              value: lessonCount.toString(),
                              icon: Icons.schedule_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Text(
                    'Hesap Detayları',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          context,
                          label: 'E-posta',
                          value: email,
                          icon: Icons.email_outlined,
                        ),
                        _buildProfileTile(
                          context,
                          label: 'Branş',
                          value: displaySubject,
                          icon: Icons.school_outlined,
                        ),
                        _buildProfileTile(
                          context,
                          label: 'Üyelik Durumu',
                          value: 'Aktif',
                          icon: Icons.verified_user_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Text(
                    'Uygulama Ayarları',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Bildirimler'),
                          subtitle: const Text(
                            'Ders ve ödeme hatırlatmaları alın.',
                          ),
                          value: notificationsEnabled,
                          onChanged: (value) async {
                            ref
                                    .read(notificationsEnabledProvider.notifier)
                                    .state =
                                value;
                            if (value) {
                              await ref
                                  .read(notificationServiceProvider)
                                  .requestPermissions();
                            } else {
                              await ref
                                  .read(notificationServiceProvider)
                                  .cancelAllScheduledNotifications();
                            }
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.dark_mode_outlined,
                            color: AppColors.primary,
                          ),
                          title: const Text('Tema'),
                          trailing: DropdownButton<ThemeMode>(
                            value: themeMode,
                            items: const [
                              DropdownMenuItem(
                                value: ThemeMode.system,
                                child: Text('Sistem'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.light,
                                child: Text('Açık'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.dark,
                                child: Text('Koyu'),
                              ),
                            ],
                            onChanged: (mode) {
                              if (mode != null) {
                                ref.read(themeModeProvider.notifier).state =
                                    mode;
                              }
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.language_outlined,
                            color: AppColors.primary,
                          ),
                          title: const Text('Dil'),
                          trailing: DropdownButton<Locale>(
                            value: locale,
                            items: const [
                              DropdownMenuItem(
                                value: Locale('tr'),
                                child: Text('Türkçe'),
                              ),
                              DropdownMenuItem(
                                value: Locale('en'),
                                child: Text('English'),
                              ),
                            ],
                            onChanged: (localeValue) {
                              if (localeValue != null) {
                                ref.read(localeProvider.notifier).state =
                                    localeValue;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Text(
                    'Veri Özeti',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          context,
                          label: 'Toplam Öğrenci',
                          value: studentCount.toString(),
                          icon: Icons.people_alt_rounded,
                        ),
                        _buildProfileTile(
                          context,
                          label: 'Toplam Ders',
                          value: lessonCount.toString(),
                          icon: Icons.schedule_rounded,
                        ),
                        _buildProfileTile(
                          context,
                          label: 'Toplam Kazanç',
                          value: AppHelpers.formatCurrency(totalEarnings),
                          icon: Icons.currency_lira_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      studentsStream.when(
                        data: (students) {
                          lessonsStream.when(
                            data: (lessons) {
                              paymentsStream.when(
                                data: (payments) {
                                  copyCsvData(
                                    context,
                                    students,
                                    lessons,
                                    payments,
                                  );
                                },
                                loading: () {},
                                error: (_, __) {},
                              );
                            },
                            loading: () {},
                            error: (_, __) {},
                          );
                        },
                        loading: () {},
                        error: (_, __) {},
                      );
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Verileri Dışa Aktar (CSV)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.p16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r20),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Text(
                    'Hakkında',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildActionTile(
                    context,
                    title: 'Kullanım Koşulları',
                    icon: Icons.gavel_outlined,
                    color: AppColors.primary,
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'Kullanım Koşulları',
                        'Kullanım koşulları içeriği daha sonra eklenecektir.',
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    title: 'Gizlilik Politikası',
                    icon: Icons.privacy_tip_outlined,
                    color: AppColors.secondary,
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'Gizlilik Politikası',
                        'Gizlilik politikası içeriği daha sonra eklenecektir.',
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    title: 'Bize Ulaşın',
                    icon: Icons.mail_outline,
                    color: AppColors.primary,
                    onTap: () {
                      _showInfoDialog(
                        context,
                        'Bize Ulaşın',
                        'support@dershub.com adresinden bize ulaşabilirsiniz.',
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Text(
                    'Hesap',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.lock_reset_outlined,
                            color: AppColors.primary,
                          ),
                          title: const Text('Şifre Sıfırlama Maili Gönder'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          onTap: () async {
                            final userEmail = email;
                            try {
                              await ref
                                  .read(authServiceProvider)
                                  .resetPassword(userEmail);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Şifre sıfırlama maili gönderildi.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hata: ${e.toString()}'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.logout_outlined,
                            color: AppColors.error,
                          ),
                          title: const Text('Oturumu Kapat'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          onTap: () async {
                            await ref.read(authServiceProvider).signOut();
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_forever_outlined,
                            color: AppColors.error,
                          ),
                          title: const Text('Hesabı Sil'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          onTap: () {
                            _showDeleteAccountDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const Scaffold(
        body: Center(
          child: Text('Profil bilgileri yüklenirken bir hata oluştu.'),
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.p8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.r20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: AppSizes.p12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text(
            'Hesap silme özelliği şu anda desteklenmiyor. Gelecekte eklenecektir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}
