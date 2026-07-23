import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<void> scheduleMaintenanceNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    int advanceWarningDays = 1,
  }) async {
    final warningDate = scheduledDate.subtract(Duration(days: advanceWarningDays));

    // Schedule advance warning notification
    if (warningDate.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        "warning_$id".hashCode, // Distinct ID for advance warning
        'اقتراب موعد صيانة: $title',
        'موعد الصيانة الدورية بعد $advanceWarningDays أيام.',
        tz.TZDateTime.from(warningDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'maintenance_warning_channel',
            'Maintenance Warnings',
            channelDescription: 'Advance warnings for scheduled device maintenance',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // Schedule the actual day notification
    if (scheduledDate.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'maintenance_channel',
            'Maintenance Notifications',
            channelDescription: 'Notifications for scheduled device maintenance',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
