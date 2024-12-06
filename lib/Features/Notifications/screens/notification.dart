import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import '../local_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  DateTime? _selectedDateTime;
  Duration _remainingTime = Duration.zero;
  Timer? _timer;
  List<PendingNotificationRequest> _pendingNotifications = [];
  int _notificationId = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _checkPendingNotifications();
  }

  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(DateTime scheduledTime) async {
    _notificationId++;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId,
      'Scheduled Notification',
      'This notification is scheduled for ${scheduledTime.toString()}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );

    _checkPendingNotifications();
    _startCountdown(scheduledTime);
  }

  Future<void> _checkPendingNotifications() async {
    final pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    setState(() {
      _pendingNotifications = pendingNotifications;
    });

    if (pendingNotifications.isNotEmpty && _selectedDateTime != null) {
      _startCountdown(_selectedDateTime!);
    } else {
      _resetCountdown();
    }
  }

  void _startCountdown(DateTime scheduledTime) {
    _timer?.cancel();
    _updateRemainingTime(scheduledTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _updateRemainingTime(scheduledTime);
      });
    });
  }

  void _updateRemainingTime(DateTime scheduledTime) {
    final now = DateTime.now();
    if (now.isBefore(scheduledTime)) {
      setState(() {
        _remainingTime = scheduledTime.difference(now);
      });
    } else {
      _resetCountdown();
    }
  }

  void _resetCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingTime = Duration.zero;
    });
  }

  void _cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    _checkPendingNotifications();
  }

  void _cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    _checkPendingNotifications();
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.toLocal().hour.toString().padLeft(2, '0')}:${dateTime.toLocal().minute.toString().padLeft(2, '0')} ${dateTime.toLocal().day.toString().padLeft(2, '0')}-${dateTime.toLocal().month.toString().padLeft(2, '0')}-${dateTime.toLocal().year}';
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
            _buildCountdown(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildPendingNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          _remainingTime.inSeconds > 0
              ? _formatDuration(_remainingTime)
              : '00:00:00',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          _buildInstantNotificationButton(),
          const SizedBox(width: 5),
          _buildRepeatedNotificationButton(),
          const SizedBox(width: 5),
          _buildScheduleNotificationButton(),
          const SizedBox(width: 5),
          _buildClearAllNotificationsButton(),
        ],
      ),
    );
  }

  Widget _buildInstantNotificationButton() {
    return ElevatedButton.icon(
      onPressed: () {
        LocalNotificationService.showBasicNotification(
          5,
          'Instant Notification',
          'The body of the notification',
        );
      },
      icon: const Icon(
        Icons.notification_important,
        color: Colors.white,
      ),
      label: Text(
        'Instant',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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

  Widget _buildRepeatedNotificationButton() {
    return ElevatedButton.icon(
      onPressed: () {
        LocalNotificationService.repeatedNotification();
      },
      icon: const Icon(
        Icons.repeat,
        color: Colors.white,
      ),
      label: Text(
        'Repeated',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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

  Widget _buildScheduleNotificationButton() {
    return ElevatedButton.icon(
      onPressed: _pickDateTime,
      icon: const Icon(
        Icons.schedule,
        color: Colors.white,
      ),
      label: Text(
        'Schedule',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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

  Widget _buildClearAllNotificationsButton() {
    return ElevatedButton.icon(
      onPressed: _cancelAllNotifications,
      icon: const Icon(
        Icons.clear_all,
        color: Colors.white,
      ),
      label: Text(
        'Clear All',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _pendingNotifications.length,
      itemBuilder: (context, index) {
        final notification = _pendingNotifications[index];
        return Card(
          color: Colors.blue[100],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              'Scheduled for ${_formatDateTime(_selectedDateTime!)}',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                _cancelNotification(notification.id!);
              },
            ),
          ),
        );
      },
    );
  }
}
