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
  Duration _remainingTime = Duration.zero;
  Timer? _timer;
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _checkPendingNotifications();
    LocalNotificationService.init();
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      debugPrint("Notification permission already granted.");
      return;
    }
    final status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint("Notification permission granted.");
    } else if (status.isDenied) {
      debugPrint("Notification permission denied.");
    } else if (status.isPermanentlyDenied) {
      debugPrint("Notification permission permanently denied.");
      openAppSettings();
    }
  }

  Future<void> _scheduleNotification(DateTime scheduledTime) async {
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

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

    await LocalNotificationService.flutterLocalNotificationsPlugin
        .zonedSchedule(
      notificationId,
      'Scheduled Notification',
      'This notification is scheduled for ${scheduledTime.toString()}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time, // Optional for daily
    );

    _checkPendingNotifications();
    //  _startCountdown(scheduledTime);
  }

  Future<void> _checkPendingNotifications() async {
    final pendingNotifications = await LocalNotificationService
        .flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    setState(() {
      _pendingNotifications = pendingNotifications;
      if (_pendingNotifications.isEmpty) {
        // _resetCountdown();
        _selectedDateTime = null;
      }
    });
  }

  // void _startCountdown(DateTime scheduledTime) {
  //   _timer?.cancel();
  //   _updateRemainingTime(scheduledTime);
  //
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     setState(() {
  //       _updateRemainingTime(scheduledTime);
  //     });
  //   });
  // }
  //
  // void _updateRemainingTime(DateTime scheduledTime) {
  //   final now = DateTime.now();
  //   if (now.isBefore(scheduledTime)) {
  //     setState(() {
  //       _remainingTime = scheduledTime.difference(now);
  //     });
  //   } else {
  //     _resetCountdown();
  //   }
  // }
  //
  // void _resetCountdown() {
  //   _timer?.cancel();
  //   setState(() {
  //     _remainingTime = Duration.zero;
  //   });
  // }

  void _cancelNotification(int id) async {
    await LocalNotificationService.flutterLocalNotificationsPlugin.cancel(id);
    _checkPendingNotifications();
  }

  void _cancelAllNotifications() async {
    await LocalNotificationService.flutterLocalNotificationsPlugin.cancelAll();
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

  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   super.dispose();
  // }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
            SizedBox(
              height: 200,
              child: AnalogClock(
                  secondHandColor: Colors.white,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2.0, color: Colors.blue[800]!),
                      color: Colors.transparent,
                      shape: BoxShape.circle),
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
                  datetime: DateTime.now()),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildClearAllNotificationsButton(),
            const SizedBox(height: 20),
            _pendingNotifications.isEmpty
                ? const Center(
                    child: Text('There is no pending notification'),
                  )
                : _buildPendingNotificationsList(),
          ],
        ),
      ),
    );
  }

  // Widget _buildCountdown() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: const [
  //         BoxShadow(
  //           color: Colors.black26,
  //           blurRadius: 8,
  //           offset: Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     padding: const EdgeInsets.symmetric(vertical: 20),
  //     child: Center(
  //       child: Text(
  //         _remainingTime.inSeconds > 0
  //             ? _formatDuration(_remainingTime)
  //             : '00:00:00',
  //         style: const TextStyle(
  //           fontSize: 48,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.blueAccent,
  //           fontFamily: 'Courier',
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionButtons() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 130,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          _buildInstantNotificationButton(),
          const VerticalDivider(
            color: Colors.white,
          ),
          _buildRepeatedNotificationButton(),
          const VerticalDivider(
            color: Colors.white,
          ),
          _buildScheduleNotificationButton(),
          const VerticalDivider(
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildInstantNotificationButton() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            LocalNotificationService.showBasicNotification(
              1,
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
        ),
        ElevatedButton.icon(
          onPressed: () {
            _cancelNotification(1);
          },
          icon: const Icon(
            Icons.cancel,
            color: Colors.white,
          ),
          label: Text(
            'Cancel',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

  Widget _buildRepeatedNotificationButton() {
    return Column(
      children: [
        ElevatedButton.icon(
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
        ),
        ElevatedButton.icon(
          onPressed: () {
            _cancelNotification(2);
          },
          icon: const Icon(
            Icons.cancel,
            color: Colors.white,
          ),
          label: Text(
            'Cancel',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

  Widget _buildScheduleNotificationButton() {
    return Column(children: [
      ElevatedButton.icon(
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
      ),
      ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.cancel,
          color: Colors.white,
        ),
        label: Text(
          'Cancel',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )
    ]);
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
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
}
