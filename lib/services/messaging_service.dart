import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
        print('Twilio SMS Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Twilio SMS Exception: $e');
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
        print('Twilio WhatsApp Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Twilio WhatsApp Exception: $e');
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
      print('Could not launch WhatsApp');
    }
  }

  /// Cihazdaki SMS uygulamasını açar (Fallback / Manuel Gönderim)
  Future<void> launchSmsApp({required String to, required String message}) async {
    final url = Uri.parse('sms:$to?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch SMS App');
    }
  }
}
