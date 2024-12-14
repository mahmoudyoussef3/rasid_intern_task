import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rasid_intern_taks/Features/Notifications/widgets/build_notification_button.dart';
import 'package:rasid_intern_taks/Features/Notifications/widgets/show_analog_clock.dart';
import 'package:timezone/timezone.dart' as tz;
import '../local_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DateTime? _selectedDateTime;
  List _pendingNotifications = [];
  int scheduledNotificationId = 3;

  @override
  void initState() {
    super.initState();
    LocalNotificationService().requestNotificationPermission();
    getPendingNotifications();
  }

  Future<void> _scheduleNotification(DateTime scheduledTime) async {
    const androidDetails = AndroidNotificationDetails(
      'default_notification_channel_id',
      'Default Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await LocalNotificationService.flutterLocalNotificationsPlugin
        .zonedSchedule(
      scheduledNotificationId++,
      'Scheduled Notification',
      'This notification is scheduled for ${scheduledTime.toString()}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'payloadData',
    );
    exampleUsage();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pendingNotifications = await LocalNotificationService
          .flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      setState(() {
        _pendingNotifications = pendingNotifications;
      });
      return pendingNotifications;
    } catch (e) {
      return [];
    }
  }

  Future<bool> hasPendingNotifications() async {
    final pendingNotifications = await getPendingNotifications();
    return pendingNotifications.isNotEmpty;
  }

  Future<void> printPendingNotificationsDetails() async {
    final pendingNotifications = await getPendingNotifications();

    if (pendingNotifications.isEmpty) {
      if (kDebugMode) {
        print('No pending notifications.');
      }
      return;
    }

    print('Pending Notifications Details:');
    for (var notification in pendingNotifications) {
      print('---');
      print('ID: ${notification.id}');
      print('Title: ${notification.title}');
      print('Body: ${notification.body}');
      print('Payload: ${notification.payload}');
    }
  }

  void exampleUsage() async {
    bool hasPending = await hasPendingNotifications();
    print('Has pending notifications: $hasPending');

    await printPendingNotificationsDetails();
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });

        if (_selectedDateTime!.isAfter(DateTime.now())) {
          _scheduleNotification(_selectedDateTime!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Notification scheduled at $_selectedDateTime')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a future time!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(child: _buildBody()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Manage Notifications',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue[800],
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[200]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShowAnalogClock(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildClearAllNotificationsButton(),
            const SizedBox(height: 20),
            _pendingNotifications.isEmpty
                ? const SizedBox(
                    height: 300,
                    child: Center(
                        child: Text(
                      'There is no pending notification',
                      style: TextStyle(fontSize: 24),
                    )))
                : _buildPendingNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 130,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          _buildInstantNotificationButton(),
          const VerticalDivider(color: Colors.white),
          _buildRepeatedNotificationButton(),
          const VerticalDivider(color: Colors.white),
          _buildScheduleNotificationButton(),
          const VerticalDivider(color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildInstantNotificationButton() {
    return BuildNotificationButton(
        label: 'Instant',
        icon: Icons.notification_important,
        onPressed: () {
          LocalNotificationService.showBasicNotification();
        },
        id: 1);
  }

  Widget _buildRepeatedNotificationButton() {
    return BuildNotificationButton(
        label: 'Repeated',
        icon: Icons.repeat,
        onPressed: () {
          LocalNotificationService.repeatedNotification();
          getPendingNotifications();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              content: Text(
                'Notification repeated every minute',
                style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
          );
        },
        id: 2);
  }

  Widget _buildScheduleNotificationButton() {
    return BuildNotificationButton(
        label: 'Schedule',
        icon: Icons.schedule,
        onPressed: _pickDateTime,
        id: 3);
  }

  Widget _buildClearAllNotificationsButton() {
    return ElevatedButton.icon(
      onPressed: () {
        LocalNotificationService().cancelAllNotifications();
        getPendingNotifications();
      },
      icon: const Icon(Icons.clear_all, color: Colors.white),
      label: Text(
        'Clear All',
        style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPendingNotificationsList() {
    return SizedBox(
      width: 300,
      height: 300,
      child: ListView.builder(
        itemCount: _pendingNotifications.length,
        itemBuilder: (context, index) {
          final notification = _pendingNotifications[index];
          return Card(
            color: Colors.blue[100],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                'Scheduled Notification ID: ${notification.id}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  LocalNotificationService()
                      .cancelNotification(notification.id);
                  getPendingNotifications();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
