import 'package:intl/intl.dart';

class AppHelpers {
  // Format currency to Turkish Lira
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format date to readable Turkish format (e.g. 21 Mayıs 2026)
  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
  }

  // Format time to 24 hour format (e.g. 14:30)
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'tr_TR').format(time);
  }

  // Combine Date & Time into beautiful string
  static String formatDateTime(DateTime date, DateTime time) {
    return '${formatDate(date)} - ${formatTime(time)}';
  }

  // Input Validation Helper
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi boş bırakılamaz.';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz.';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName alanı boş bırakılamaz.';
    }
    return null;
  }
}
