import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/lesson.dart';
import '../models/lesson_status.dart';
import '../models/student.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService();
});

class MessagingService {
  // TODO: Replace with real Twilio credentials if using in production.
  final String _twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  final String _twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
  final String _twilioFromNumber = '+1234567890'; // SMS from number
  final String _twilioWhatsAppFrom = 'whatsapp:+14155238886'; // Twilio sandbox number

  /// Twilio API ile SMS gönderir
  Future<bool> sendSmsViaTwilio({required String to, required String message}) async {
    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json');
    final auth = 'Basic ${base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioFromNumber,
          'To': to,
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Twilio SMS Error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Twilio SMS Exception: $e');
      return false;
    }
  }

  /// Twilio API ile WhatsApp mesajı gönderir
  Future<bool> sendWhatsAppViaTwilio({required String to, required String message}) async {
    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json');
    final auth = 'Basic ${base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}';

    // Twilio WhatsApp numarası formati: 'whatsapp:+905551234567'
    final toWhatsapp = to.startsWith('whatsapp:') ? to : 'whatsapp:$to';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioWhatsAppFrom,
          'To': toWhatsapp,
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Twilio WhatsApp Error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Twilio WhatsApp Exception: $e');
      return false;
    }
  }

  /// Cihazdaki WhatsApp uygulamasını açar (Fallback / Manuel Gönderim)
  Future<void> launchWhatsAppApp({required String to, required String message}) async {
    // Numaradaki boşlukları ve artı işaretini temizle (WhatsApp wa.me linki için)
    final cleanNumber = to.replaceAll('+', '').replaceAll(' ', '');
    final url = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch WhatsApp');
    }
  }

  /// Cihazdaki SMS uygulamasını açar (Fallback / Manuel Gönderim)
  Future<void> launchSmsApp({required String to, required String message}) async {
    final url = Uri.parse('sms:$to?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch SMS App');
    }
  }

  // ─── FAZ 2: Şablon Mesaj Üreticileri ───────────────────────────────────────

  static final _dateFmt = DateFormat('d MMMM yyyy', 'tr_TR');
  static final _timeFmt = DateFormat('HH:mm', 'tr_TR');

  /// İptal mesajı şablonu (WhatsApp veya SMS için hazır metin)
  String buildCancellationMessage({
    required Student student,
    required Lesson lesson,
    required LessonStatus cancelledBy,
    String? reason,
  }) {
    final dateStr = _dateFmt.format(lesson.dateTime);
    final timeStr = _timeFmt.format(lesson.dateTime);
    final who = cancelledBy == LessonStatus.cancelledByTeacher
        ? 'Öğretmen tarafından'
        : 'Öğrenci tarafından';

    final buf = StringBuffer();
    buf.write('Merhaba ${student.nickname},\n\n');
    buf.write(
        '$dateStr tarihli, saat $timeStr\'deki dersiniz $who iptal edilmiştir.');
    if (lesson.topic.isNotEmpty) {
      buf.write(' (Konu: ${lesson.topic})');
    }
    if (reason != null && reason.isNotEmpty) {
      buf.write('\n\nSebep: $reason');
    }
    if (cancelledBy == LessonStatus.cancelledByTeacher) {
      buf.write('\n\nTelafi dersi hakkınız tanınmıştır, en kısa sürede yeni '
          'bir ders planlanacaktır.');
    }
    buf.write('\n\nİyi günler dileriz.');
    return buf.toString();
  }

  /// Erteleme mesajı şablonu
  String buildRescheduleMessage({
    required Student student,
    required Lesson originalLesson,
    required DateTime newDateTime,
    String? reason,
  }) {
    final oldDate = _dateFmt.format(originalLesson.dateTime);
    final oldTime = _timeFmt.format(originalLesson.dateTime);
    final newDate = _dateFmt.format(newDateTime);
    final newTime = _timeFmt.format(newDateTime);

    final buf = StringBuffer();
    buf.write('Merhaba ${student.nickname},\n\n');
    buf.write(
        '$oldDate tarihli, saat $oldTime\'deki dersiniz ertelenmiştir.');
    buf.write('\n\nYeni ders zamanı: $newDate – saat $newTime.');
    if (reason != null && reason.isNotEmpty) {
      buf.write('\n\nSebep: $reason');
    }
    buf.write('\n\nİyi günler dileriz.');
    return buf.toString();
  }

  /// Telafi dersi bildirimi şablonu
  String buildCompensationMessage({
    required Student student,
    required DateTime compensationDateTime,
  }) {
    final dateStr = _dateFmt.format(compensationDateTime);
    final timeStr = _timeFmt.format(compensationDateTime);

    return 'Merhaba ${student.nickname},\n\n'
        'Bekleyen telafi dersiniz için yeni bir ders planlandı.\n'
        'Telafi dersi: $dateStr – saat $timeStr.\n\n'
        'İyi günler dileriz.';
  }

  /// WhatsApp veya SMS launch: mesaj şablonunu kullanıcıya hazır gönderir
  Future<void> sendCancellationWhatsApp({
    required Student student,
    required Lesson lesson,
    required LessonStatus cancelledBy,
    String? reason,
  }) async {
    final phone = student.phoneNumber;
    if (phone == null || phone.isEmpty) return;
    final message = buildCancellationMessage(
      student: student,
      lesson: lesson,
      cancelledBy: cancelledBy,
      reason: reason,
    );
    await launchWhatsAppApp(to: phone, message: message);
  }

  Future<void> sendCancellationSms({
    required Student student,
    required Lesson lesson,
    required LessonStatus cancelledBy,
    String? reason,
  }) async {
    final phone = student.phoneNumber;
    if (phone == null || phone.isEmpty) return;
    final message = buildCancellationMessage(
      student: student,
      lesson: lesson,
      cancelledBy: cancelledBy,
      reason: reason,
    );
    await launchSmsApp(to: phone, message: message);
  }

  Future<void> sendRescheduleWhatsApp({
    required Student student,
    required Lesson originalLesson,
    required DateTime newDateTime,
    String? reason,
  }) async {
    final phone = student.phoneNumber;
    if (phone == null || phone.isEmpty) return;
    final message = buildRescheduleMessage(
      student: student,
      originalLesson: originalLesson,
      newDateTime: newDateTime,
      reason: reason,
    );
    await launchWhatsAppApp(to: phone, message: message);
  }

  Future<void> sendRescheduleSms({
    required Student student,
    required Lesson originalLesson,
    required DateTime newDateTime,
    String? reason,
  }) async {
    final phone = student.phoneNumber;
    if (phone == null || phone.isEmpty) return;
    final message = buildRescheduleMessage(
      student: student,
      originalLesson: originalLesson,
      newDateTime: newDateTime,
      reason: reason,
    );
    await launchSmsApp(to: phone, message: message);
  }
}
