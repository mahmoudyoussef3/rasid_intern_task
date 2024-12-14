import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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

  static void showBasicNotification() async {
    NotificationDetails details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_notification_channel_id',
        'Default Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
        1, 'Instant Notification', 'The body of the notification', details,
        payload: 'payloadData');
  }

  static void repeatedNotification() async {
    NotificationDetails details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_notification_channel_id',
        'Default Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await flutterLocalNotificationsPlugin.periodicallyShow(
      2,
      'This is repeated Notification',
      'Repeated notification every minute',
      RepeatInterval.everyMinute,
      details,
      payload: 'payloadData',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  void cancelNotification(int id) async {
    await LocalNotificationService.flutterLocalNotificationsPlugin.cancel(id);
  }

  void cancelAllNotifications() async {
    await LocalNotificationService.flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint("Notification permission granted.");
    } else {
      debugPrint("Notification permission denied.");
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }
}
