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

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  Future<void> _copyCsvData(
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV verileri panoya kopyalandı.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showEditProfileDialog(String currentName, String currentSubject) {
    final nameController = TextEditingController(text: currentName);
    final subjectController = TextEditingController(text: currentSubject);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Profili Düzenle'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSizes.p16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Branş',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();
                final subject = subjectController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ad Soyad boş bırakılamaz.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                try {
                  await ref.read(authServiceProvider).updateTeacherProfile(
                        fullName: name,
                        subject: subject.isEmpty ? 'Genel Ders' : subject,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil başarıyla güncellendi.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Kaydet'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Hesabı Sil'),
            ],
          ),
          content: const Text(
            'Hesabınız ve tüm verileriniz kalıcı olarak silinecektir. Bu işlem geri alınamaz.\n\nDevam etmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await ref.read(authServiceProvider).deleteAccount();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hesabınız başarıyla silindi.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Hesabı Sil'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r24),
          ),
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

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopyalandı: $value'),
        backgroundColor: AppColors.primary,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // ── Profile Header Card ──
                  GestureDetector(
                    onTap: () => _showEditProfileDialog(
                      displayName,
                      displaySubject,
                    ),
                    child: Container(
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
                                  color:
                                      Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0]
                                        : 'D',
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSizes.p4),
                                    Text(
                                      displaySubject,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.p24),
                          Text(
                            'Profil Özeti',
                            style:
                                theme.textTheme.titleMedium?.copyWith(
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
                  ),

                  const SizedBox(height: AppSizes.p24),

                  // ── Hesap Detayları ──
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
                        _buildTappableProfileTile(
                          label: 'E-posta',
                          value: email,
                          icon: Icons.email_outlined,
                          onTap: () => _copyToClipboard('E-posta', email),
                        ),
                        _buildTappableProfileTile(
                          label: 'Branş',
                          value: displaySubject,
                          icon: Icons.school_outlined,
                          onTap: () => _showEditProfileDialog(
                            displayName,
                            displaySubject,
                          ),
                          trailing: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        _buildTappableProfileTile(
                          label: 'Üyelik Durumu',
                          value: 'Aktif',
                          icon: Icons.verified_user_outlined,
                          onTap: () => _showInfoDialog(
                            'Üyelik Durumu',
                            'Hesabınız aktif durumda. Tüm özelliklerden yararlanabilirsiniz.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.p24),

                  // ── Uygulama Ayarları ──
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

                  // ── Veri Özeti ──
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
                        _buildTappableProfileTile(
                          label: 'Toplam Öğrenci',
                          value: studentCount.toString(),
                          icon: Icons.people_alt_rounded,
                          onTap: () => _showInfoDialog(
                            'Toplam Öğrenci',
                            'Şu anda $studentCount kayıtlı öğrenciniz bulunmaktadır.',
                          ),
                        ),
                        _buildTappableProfileTile(
                          label: 'Toplam Ders',
                          value: lessonCount.toString(),
                          icon: Icons.schedule_rounded,
                          onTap: () => _showInfoDialog(
                            'Toplam Ders',
                            'Toplamda $lessonCount adet ders kaydınız bulunmaktadır.',
                          ),
                        ),
                        _buildTappableProfileTile(
                          label: 'Toplam Kazanç',
                          value: AppHelpers.formatCurrency(totalEarnings),
                          icon: Icons.currency_lira_rounded,
                          onTap: () => _showInfoDialog(
                            'Toplam Kazanç',
                            'Ödendi olarak işaretlenen derslerden toplam ${AppHelpers.formatCurrency(totalEarnings)} kazanç elde ettiniz.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.p16),

                  // ── Verileri Dışa Aktar ──
                  ElevatedButton.icon(
                    onPressed: () async {
                      studentsStream.when(
                        data: (students) {
                          lessonsStream.when(
                            data: (lessons) {
                              paymentsStream.when(
                                data: (payments) {
                                  _copyCsvData(students, lessons, payments);
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

                  // ── Hakkında ──
                  Text(
                    'Hakkında',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildActionTile(
                    title: 'Kullanım Koşulları',
                    icon: Icons.gavel_outlined,
                    color: AppColors.primary,
                    onTap: () {
                      _showInfoDialog(
                        'Kullanım Koşulları',
                        'Bu uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursunuz:\n\n'
                            '1. Uygulama eğitim amaçlı özel ders yönetimi için tasarlanmıştır.\n'
                            '2. Kişisel verilerinizin güvenliği bizim için önemlidir.\n'
                            '3. Uygulama içeriğinin izinsiz kopyalanması yasaktır.\n'
                            '4. Hizmet kalitesini artırmak için anonim kullanım verileri toplanabilir.',
                      );
                    },
                  ),
                  _buildActionTile(
                    title: 'Gizlilik Politikası',
                    icon: Icons.privacy_tip_outlined,
                    color: AppColors.secondary,
                    onTap: () {
                      _showInfoDialog(
                        'Gizlilik Politikası',
                        'Gizlilik politikamız hakkında bilgilendirme:\n\n'
                            '• Verileriniz Firebase altyapısında güvenle saklanır.\n'
                            '• Kişisel bilgileriniz üçüncü taraflarla paylaşılmaz.\n'
                            '• Hesap silme talebiniz halinde tüm verileriniz kalıcı olarak silinir.\n'
                            '• Sorularınız için support@dershub.com adresinden bize ulaşabilirsiniz.',
                      );
                    },
                  ),
                  _buildActionTile(
                    title: 'Bize Ulaşın',
                    icon: Icons.mail_outline,
                    color: AppColors.primary,
                    onTap: () {
                      _showContactDialog();
                    },
                  ),
                  _buildActionTile(
                    title: 'Uygulama Sürümü',
                    icon: Icons.info_outline_rounded,
                    color: AppColors.accent,
                    onTap: () {
                      _showInfoDialog(
                        'Uygulama Bilgileri',
                        'DersHub v1.0.0\n\n'
                            'Geliştirici: DersHub Ekibi\n'
                            'Platform: Flutter / Firebase\n'
                            '© 2026 DersHub. Tüm hakları saklıdır.',
                      );
                    },
                  ),

                  const SizedBox(height: AppSizes.p24),

                  // ── Hesap ──
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
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Şifre sıfırlama maili gönderildi.',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hata: ${e.toString()}'),
                                    backgroundColor: AppColors.error,
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
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.r24),
                                ),
                                title: const Text('Oturumu Kapat'),
                                content: const Text(
                                  'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('İptal'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('Çıkış Yap'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref.read(authServiceProvider).signOut();
                            }
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
                          onTap: () => _showDeleteAccountDialog(),
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

  // ── Helper Widgets ──

  Widget _buildTappableProfileTile({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(value),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
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

  void _showContactDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mail_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Bize Ulaşın'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sorularınız veya önerileriniz için bizimle iletişime geçebilirsiniz.',
              ),
              const SizedBox(height: AppSizes.p16),
              InkWell(
                onTap: () => _copyToClipboard(
                  'E-posta',
                  'support@dershub.com',
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'support@dershub.com',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}
