import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../models/payment.dart';
import '../../services/database_service.dart';

class PaymentsView extends ConsumerStatefulWidget {
  const PaymentsView({super.key});

  @override
  ConsumerState<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends ConsumerState<PaymentsView> {
  String _selectedStatus = 'all';
  String _selectedStudentId = 'all';
  DateTimeRange? _selectedDateRange;

  final List<String> _paymentMethods = [
    'Nakit',
    'Kart',
    'Banka Havalesi',
    'Mobil Ödeme',
  ];

  @override
  Widget build(BuildContext context) {
    final paymentsResult = ref.watch(paymentsStreamProvider);
    final studentsResult = ref.watch(studentsStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (paymentsResult.isLoading || studentsResult.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (paymentsResult.hasError || studentsResult.hasError) {
      final errorText =
          paymentsResult.error?.toString() ??
          studentsResult.error?.toString() ??
          'Bilinmeyen hata';
      return Scaffold(body: Center(child: Text('Hata oluştu: $errorText')));
    }

    final payments = paymentsResult.requireValue;
    final students = studentsResult.requireValue;

    final filteredPayments = payments.where((payment) {
      if (_selectedStatus != 'all' && payment.status != _selectedStatus) {
        return false;
      }
      if (_selectedStudentId != 'all' &&
          payment.studentId != _selectedStudentId) {
        return false;
      }
      if (_selectedDateRange != null) {
        final dueDate = payment.dueDate;
        if (dueDate.isBefore(_selectedDateRange!.start) ||
            dueDate.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }
      return true;
    }).toList();

    double pendingPayments = 0;
    double overduePayments = 0;
    for (final payment in filteredPayments) {
      switch (payment.status) {
        case 'paid':
          break;
        case 'pending':
          pendingPayments += payment.amount;
          break;
        case 'overdue':
          overduePayments += payment.amount;
          break;
        default:
          pendingPayments += payment.amount;
      }
    }

    final now = DateTime.now();
    final paidThisMonth = filteredPayments
        .where((p) => p.status == 'paid' && p.paymentDate != null)
        .where(
          (p) =>
              p.paymentDate!.year == now.year &&
              p.paymentDate!.month == now.month,
        )
        .fold<double>(0, (sum, p) => sum + p.amount);
    final paidThisYear = filteredPayments
        .where((p) => p.status == 'paid' && p.paymentDate != null)
        .where((p) => p.paymentDate!.year == now.year)
        .fold<double>(0, (sum, p) => sum + p.amount);
    final pendingTotal = pendingPayments + overduePayments;

    final statusCounts = {
      'paid': filteredPayments.where((p) => p.status == 'paid').length,
      'pending': filteredPayments.where((p) => p.status == 'pending').length,
      'overdue': filteredPayments.where((p) => p.status == 'overdue').length,
    };

    final monthlyTotals = <String, double>{};
    for (final payment in filteredPayments) {
      final monthKey =
          '${payment.dueDate.year}-${payment.dueDate.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + payment.amount;
    }

    final sortedMonthKeys = monthlyTotals.keys.toList()..sort();
    final groupedPayments = <String, List<Payment>>{};
    for (final payment in filteredPayments) {
      final monthKey =
          '${payment.dueDate.year}-${payment.dueDate.month.toString().padLeft(2, '0')}';
      groupedPayments.putIfAbsent(monthKey, () => []).add(payment);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kazanç Raporu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16).copyWith(bottom: 92),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        context,
                        label: 'Durum',
                        value: _selectedStatus,
                        options: const {
                          'all': 'Tümü',
                          'paid': 'Ödenen',
                          'pending': 'Bekleyen',
                          'overdue': 'Geciken',
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: _buildFilterChip(
                        context,
                        label: 'Öğrenci',
                        value: _selectedStudentId,
                        options: {
                          'all': 'Tümü',
                          for (final student in students)
                            student.id: student.nickname,
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedStudentId = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                _buildDateRangeFilter(context),
              ],
            ),
            const SizedBox(height: AppSizes.p20),
            _buildMetricCard(
              context,
              title: 'Bu Ay Toplam Kazanç',
              amount: paidThisMonth,
              subtitle: 'Ödenmiş işlemler',
              icon: Icons.trending_up_rounded,
              backgroundColor: AppColors.primaryGradient,
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Bekleyen Ödemeler',
                    amount: pendingTotal,
                    icon: Icons.hourglass_empty_rounded,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Bu Yıl Toplam',
                    amount: paidThisYear,
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            _buildStatCard(
              context,
              title: 'Gecikmiş',
              amount: overduePayments,
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.p24),
            Text(
              'Ödeme Dağılımı',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            SizedBox(height: 200, child: _buildStatusPieChart(statusCounts)),
            const SizedBox(height: AppSizes.p24),
            Text(
              'Aylık Gelir Takibi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            SizedBox(
              height: 220,
              child: _buildMonthlyBarChart(sortedMonthKeys, monthlyTotals),
            ),
            const SizedBox(height: AppSizes.p24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ödeme Geçmişi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredPayments.length} kayıt',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            if (filteredPayments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p32),
                child: Center(
                  child: Text(
                    'Filtrelere uygun ödeme kaydı bulunamadı.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              )
            else
              for (final monthKey in sortedMonthKeys)
                _buildGroupedPayments(
                  monthKey,
                  groupedPayments[monthKey] ?? [],
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCollectPaymentSheet(context, filteredPayments),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.payments_rounded),
        label: const Text('Ödeme Al'),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p12,
          vertical: AppSizes.p8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: options.entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final label = _selectedDateRange == null
        ? 'Tarih aralığı seçin'
        : '${AppHelpers.formatDate(_selectedDateRange!.start)} - ${AppHelpers.formatDate(_selectedDateRange!.end)}';

    return FilledButton.icon(
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: _selectedDateRange,
        );
        if (picked != null) {
          setState(() {
            _selectedDateRange = picked;
          });
        }
      },
      icon: const Icon(Icons.date_range_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p16,
          horizontal: AppSizes.p16,
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required double amount,
    required String subtitle,
    required IconData icon,
    required Gradient backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        gradient: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.p12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  AppHelpers.formatCurrency(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  AppHelpers.formatCurrency(amount),
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: AppSizes.p8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart(Map<String, int> statusCounts) {
    final sections = statusCounts.entries.where((entry) => entry.value > 0).map(
      (entry) {
        final color = entry.key == 'paid'
            ? AppColors.success
            : entry.key == 'pending'
            ? AppColors.warning
            : AppColors.error;
        return PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${entry.value}',
          radius: 48,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
      },
    ).toList();

    if (sections.isEmpty) {
      return Center(
        child: Text(
          'Henüz ödeme verisi yok.',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 4,
        centerSpaceRadius: 24,
      ),
    );
  }

  Widget _buildMonthlyBarChart(
    List<String> monthKeys,
    Map<String, double> monthlyTotals,
  ) {
    if (monthKeys.isEmpty) {
      return Center(
        child: Text(
          'Aylık gelir yok.',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    final maxValue = monthlyTotals.values.fold<double>(
      0,
      (prev, value) => value > prev ? value : prev,
    );
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= monthKeys.length) {
                  return const SizedBox();
                }
                final key = monthKeys[index];
                final parts = key.split('-');
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    '${parts[1]}.${parts[0].substring(2)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: monthKeys.asMap().entries.map((entry) {
          final index = entry.key;
          final key = entry.value;
          final amount = monthlyTotals[key] ?? 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: AppColors.primary,
                width: 18,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(show: false),
        maxY: maxValue < 1 ? 1 : maxValue * 1.15,
      ),
    );
  }

  Widget _buildGroupedPayments(String monthKey, List<Payment> payments) {
    final parts = monthKey.split('-');
    final monthLabel = '${parts[1]}/${parts[0]}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.p16),
        Text(
          monthLabel,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.p12),
        ...payments.map((payment) => PaymentCard(payment: payment)),
      ],
    );
  }

  void _showCollectPaymentSheet(BuildContext context, List<Payment> payments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final duePayments = payments.where((p) => p.status != 'paid').toList();
        String selectedStudentId = duePayments.isNotEmpty
            ? duePayments.first.studentId
            : 'all';
        final selectedPayments = <String>{};
        String selectedPaymentMethod = _paymentMethods.first;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final studentOptions = {
              'all': 'Tümü',
              for (final student
                  in ref.watch(studentsStreamProvider).requireValue)
                student.id: student.nickname,
            };

            if (!studentOptions.containsKey(selectedStudentId) &&
                studentOptions.isNotEmpty) {
              selectedStudentId = studentOptions.keys.first;
            }

            final studentDuePayments = duePayments
                .where(
                  (p) =>
                      selectedStudentId == 'all' ||
                      p.studentId == selectedStudentId,
                )
                .toList();

            final totalSelectedAmount = studentDuePayments
                .where((p) => selectedPayments.contains(p.id))
                .fold<double>(0, (sum, p) => sum + p.amount);

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.r24),
                  topRight: Radius.circular(AppSizes.r24),
                ),
              ),
              padding: EdgeInsets.only(
                left: AppSizes.p20,
                right: AppSizes.p20,
                top: AppSizes.p20,
                bottom: AppSizes.p20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ödeme Al',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    if (duePayments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.p32,
                        ),
                        child: Text(
                          'Ödeme almaya uygun kayıt bulunamadı.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    else ...[
                      _buildFilterChip(
                        context,
                        label: 'Öğrenci',
                        value: selectedStudentId,
                        options: studentOptions,
                        onChanged: (value) {
                          setSheetState(() {
                            selectedStudentId = value;
                            selectedPayments.clear();
                          });
                        },
                      ),
                      const SizedBox(height: AppSizes.p16),
                      if (studentDuePayments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.p32,
                          ),
                          child: Text(
                            'Seçili öğrenci için ödenmemiş ders bulunamadı.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      else ...[
                        Text(
                          'Ödenmemiş Dersler',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        ...studentDuePayments.map((payment) {
                          final isSelected = selectedPayments.contains(
                            payment.id,
                          );
                          return Card(
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (checked) {
                                setSheetState(() {
                                  if (checked == true) {
                                    selectedPayments.add(payment.id);
                                  } else {
                                    selectedPayments.remove(payment.id);
                                  }
                                });
                              },
                              title: Text(payment.studentName),
                              subtitle: Text(
                                '${AppHelpers.formatDate(payment.dueDate)} • ${AppHelpers.formatCurrency(payment.amount)}',
                              ),
                              secondary: payment.lessonId != null
                                  ? const Icon(Icons.book_rounded)
                                  : const Icon(Icons.payments_rounded),
                            ),
                          );
                        }),
                        const SizedBox(height: AppSizes.p16),
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ödeme Yöntemi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.r16),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p12,
                              vertical: AppSizes.p8,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPaymentMethod,
                              items: _paymentMethods
                                  .map(
                                    (method) => DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setSheetState(() {
                                    selectedPaymentMethod = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.p16),
                        Text(
                          'Toplam: ${AppHelpers.formatCurrency(totalSelectedAmount)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSizes.p16),
                        FilledButton(
                          onPressed: selectedPayments.isEmpty
                              ? null
                              : () async {
                                  final selected = studentDuePayments
                                      .where(
                                        (p) => selectedPayments.contains(p.id),
                                      )
                                      .toList();
                                  for (final payment in selected) {
                                    await ref
                                        .read(databaseServiceProvider)
                                        .updatePayment(
                                          payment.copyWith(
                                            status: 'paid',
                                            paymentDate: DateTime.now(),
                                            paymentMethod:
                                                selectedPaymentMethod,
                                          ),
                                        );
                                  }
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ödeme kaydedildi.'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                          child: const Text('Kaydet'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PaymentCard extends ConsumerWidget {
  final Payment payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData icon;
    switch (payment.status) {
      case 'paid':
        statusColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case 'overdue':
        statusColor = AppColors.error;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        icon = Icons.hourglass_bottom_rounded;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: statusColor, size: 22),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.studentName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.status == 'paid' && payment.paymentDate != null
                        ? '${AppHelpers.formatDate(payment.paymentDate!)} tarihinde ödendi'
                        : 'Vade: ${AppHelpers.formatDate(payment.dueDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  if (payment.paymentMethod != null &&
                      payment.paymentMethod!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Yöntem: ${payment.paymentMethod}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppHelpers.formatCurrency(payment.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: payment.status == 'paid' ? AppColors.success : null,
                  ),
                ),
                if (payment.status != 'paid') ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      try {
                        await ref
                            .read(databaseServiceProvider)
                            .markPaymentAsPaid(payment.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tahsilat gerçekleştirildi!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata oluştu: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      child: const Text(
                        'Ödendi İşaretle',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
