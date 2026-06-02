import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    _configureLocalTimeZone();
    await requestPermissions();
    await _createNotificationChannel();
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _configureLocalTimeZone() {
    tz.initializeTimeZones();
    final String timeZoneName = DateTime.now().timeZoneName;
    // +03 gibi UTC offset formatları geçersizdir; IANA adıyla fallback kullan
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    }
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'dershub_reminder_channel',
      'Dershub Hatırlatmaları',
      description: 'Ders ve ödeme hatırlatmaları için bildirim kanalı.',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  NotificationDetails get _defaultNotificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'dershub_reminder_channel',
        'Dershub Hatırlatmaları',
        channelDescription:
            'Ders ve ödeme hatırlatmaları için bildirim kanalı.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleLessonReminder({
    required DateTime dateTime,
    required String lessonTitle,
    required String studentName,
  }) async {
    final reminderDate = dateTime.subtract(const Duration(minutes: 30));
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      reminderDate.hashCode,
      'Ders Hatırlatması',
      '$studentName ile $lessonTitle dersiniz 30 dakika sonra başlıyor.',
      tz.TZDateTime.from(reminderDate, tz.local),
      _defaultNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> schedulePaymentReminder({
    required DateTime dateTime,
    required String studentName,
  }) async {
    final reminderDate = dateTime.subtract(const Duration(days: 1));
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      reminderDate.hashCode,
      'Ödeme Hatırlatması',
      '$studentName için ödeme yarın vadesi geliyor.',
      tz.TZDateTime.from(reminderDate, tz.local),
      _defaultNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> sendWelcomeNotification({required String studentName}) async {
    await _plugin.show(
      studentName.hashCode,
      'Hoş geldin!',
      '$studentName isimli öğrenci başarıyla eklendi.',
      _defaultNotificationDetails,
    );
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _plugin.cancelAll();
  }
}
