import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color primary = Color(0xFF6B4EFF);
  static const Color primaryLight = Color(0xFFD6C6FF);
  static const Color secondary = Color(0xFF00C9A7);
  static const Color accent = Color(0xFFFFB547);
  static const Color error = Color(0xFFFF5252);

  // Light Mode Backgrounds
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF5F7FA);

  // Dark Mode Backgrounds
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF25264C);
  static const Color cardDark = Color(0xFF2B2E5D);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);

  // Status & Actions
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFFB547);

  // Custom Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8D73FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSizes {
  // Margins & Paddings
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;

  // Border Radii
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;

  // Icon Sizes
  static const double iconSmall = 18.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}

class AppStrings {
  static const String appName = 'DersHub';

  // Navigation & Core Pages
  static const String students = 'Öğrenciler';
  static const String calendar = 'Takvim';
  static const String payments = 'Ödemeler';
  static const String notes = 'Notlar';
  static const String profile = 'Profil';

  // Auth Screen
  static const String welcomeBack = 'Hoş Geldiniz!';
  static const String loginSubtitle =
      'Derslerinizi ve öğrencilerinizi akıllıca yönetin.';
  static const String signUpTitle = 'Hesap Oluştur';
  static const String signUpSubtitle =
      'Özel ders yönetiminde yeni bir döneme başlayın.';
  static const String email = 'E-posta Adresi';
  static const String password = 'Şifre';
  static const String forgotPassword = 'Şifremi Unuttum';
  static const String login = 'Giriş Yap';
  static const String register = 'Kayıt Ol';
  static const String dontHaveAccount = 'Hesabınız yok mu? ';
  static const String alreadyHaveAccount = 'Zaten hesabınız var mı? ';
  static const String acceptTerms =
      'Kullanım koşullarını okudum ve kabul ediyorum.';
  static const String resetPasswordTitle = 'Şifre Sıfırlama';
  static const String resetPasswordDescription =
      'Kayıtlı e-posta adresinizi girerek şifre sıfırlama bağlantısı alabilirsiniz.';
  static const String resetPasswordSent =
      'Şifre sıfırlama e-postası gönderildi.';
  static const String sendResetLink = 'Sıfırlama Bağlantısı Gönder';
  static const String passwordNotMatch = 'Şifreler eşleşmiyor.';
  static const String splashSubtitle = 'Hesabınıza yönlendiriliyorsunuz...';

  // Placeholders / Fallbacks
  static const String activeStudents = 'Aktif Öğrenciler';
  static const String totalEarnings = 'Toplam Kazanç';
  static const String pendingPayments = 'Bekleyen Ödemeler';
  static const String upcomingLessons = 'Yaklaşan Dersler';
}
