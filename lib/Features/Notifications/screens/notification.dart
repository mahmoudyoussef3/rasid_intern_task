import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_clock/one_clock.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../local_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DateTime? _selectedDateTime;
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _checkPendingNotifications();
    LocalNotificationService.init();
  }

  Future<void> _requestNotificationPermission() async {
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
      3,
      'Scheduled Notification',
      'This notification is scheduled for ${scheduledTime.toString()}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'payloadData',
    );

    _checkPendingNotifications();
  }

  Future<void> _checkPendingNotifications() async {
    final pendingNotifications = await LocalNotificationService
        .flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    setState(() {
      _pendingNotifications = pendingNotifications;
    });
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
      body: _buildBody(),
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
            _buildClock(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildClearAllNotificationsButton(),
            const SizedBox(height: 20),
            _pendingNotifications.isEmpty
                ? const Center(child: Text('There is no pending notification'))
                : _buildPendingNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildClock() {
    return SizedBox(
      height: 200,
      child: AnalogClock(
        digitalClockColor: Colors.white,
        tickColor: Colors.white,
        secondHandColor: Colors.white,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.blue[800]!),
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        width: 150.0,
        isLive: true,
        hourHandColor: Colors.blue[800]!,
        minuteHandColor: Colors.blue[800]!,
        showSecondHand: true,
        numberColor: Colors.blue[800]!,
        showNumbers: true,
        showAllNumbers: true,
        showTicks: true,
        showDigitalClock: true,
        datetime: DateTime.now(),
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
    return _buildNotificationButton('Instant', Icons.notification_important,
        () {
      LocalNotificationService.showBasicNotification(
        1,
        'Instant Notification',
        'The body of the notification',
      );
    }, 1);
  }

  Widget _buildRepeatedNotificationButton() {
    return _buildNotificationButton('Repeated', Icons.repeat, () {
      LocalNotificationService.repeatedNotification();
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
    }, 2);
  }

  Widget _buildScheduleNotificationButton() {
    return _buildNotificationButton(
        'Schedule', Icons.schedule, _pickDateTime, 3);
  }

  Widget _buildNotificationButton(
      String label, IconData icon, VoidCallback onPressed, int id) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
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
        ),
        ElevatedButton.icon(
          onPressed: () {
            _cancelNotification(id);
          },
          icon: const Icon(Icons.cancel, color: Colors.white),
          label: Text(
            'Cancel',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildClearAllNotificationsButton() {
    return ElevatedButton.icon(
      onPressed: _cancelAllNotifications,
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
      height: 100,
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
                  _cancelNotification(notification.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _cancelNotification(int id) async {
    await LocalNotificationService.flutterLocalNotificationsPlugin.cancel(id);
    _checkPendingNotifications();
  }

  void _cancelAllNotifications() async {
    await LocalNotificationService.flutterLocalNotificationsPlugin.cancelAll();
    _checkPendingNotifications();
  }
}
