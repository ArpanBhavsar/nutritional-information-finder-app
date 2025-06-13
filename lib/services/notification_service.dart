import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine_reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // --- Android Permission Request (for API 33+) ---
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    // --- iOS Permission Request ---
    // FIX 1: The class is now IOSFlutterLocalNotificationsPlugin
    final IOSFlutterLocalNotificationsPlugin? iOSImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iOSImplementation?.requestPermissions(alert: true, badge: true, sound: true);

    // --- Initialization Settings ---
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // FIX 2: onDidReceiveLocalNotification has been completely removed.
    // Handling for foreground notifications on old iOS versions must be done natively.
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await _notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  // Unified callback for when a notification is tapped.
  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
    }
    // TODO: Add navigation logic here if needed.
  }

  Future<void> scheduleReminderNotification(MedicineReminder reminder) async {
    if (reminder.id == null) return;

    final now = tz.TZDateTime.now(tz.local);

    if (reminder.days.contains('Everyday')) {
      for (int i = 1; i <= 7; i++) {
        await _scheduleNotificationForDay(reminder, i, now);
      }
    } else {
      for (String day in reminder.days) {
        int weekday = _dayToWeekday(day);
        if (weekday > 0) {
          await _scheduleNotificationForDay(reminder, weekday, now);
        }
      }
    }
  }

  Future<void> _scheduleNotificationForDay(MedicineReminder reminder, int weekday, tz.TZDateTime now) async {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(reminder.time.hour, reminder.time.minute, weekday, now);
    int notificationId = reminder.id! * 10 + weekday;

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Time for your medicine!',
      'Don\'t forget to take your ${reminder.medicineName}.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminder_channel_id',
          'Medicine Reminders',
          channelDescription: 'Notifications for medicine reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        // FIX 3: `uiLocalNotificationDateInterpretation` is removed.
        // This is now the complete and correct way to define iOS details.
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // This is the crucial part that replaced the old interpretation parameter.
      // It tells the system to match the notification time on a weekly basis.
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, int weekday, tz.TZDateTime now) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelReminderNotification(int reminderId) async {
    for (int i = 1; i <= 7; i++) {
      int notificationId = reminderId * 10 + i;
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  int _dayToWeekday(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return 0;
    }
  }
}
