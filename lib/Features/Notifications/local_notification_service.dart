import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static onTap(NotificationResponse notificationResponse) {}

  static Future init() async {
    InitializationSettings initializationSettings =
        const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings());
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onTap,
      onDidReceiveNotificationResponse: onTap,
    );
  }

  static void showBasicNotification(int id, String title, String body) async {
    NotificationDetails details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_notification_channel_id',
        'Default Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      ),
    );
    await flutterLocalNotificationsPlugin.show(id, title, body, details,
        payload: 'payloadData');
  }

  static void repeatedNotification() async {
    NotificationDetails details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'repeatedid',
        'Default repeatedid Channel',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      ),
    );
    await flutterLocalNotificationsPlugin.periodicallyShow(
      2,
      'this is repeated Notification',
      'Repeated notification every minute',
      RepeatInterval.everyMinute,
      details,
      payload: 'payloadData',
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }
}
