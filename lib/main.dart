import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rasid_intern_taks/Features/location/cubit/location_cubit.dart';
import 'package:rasid_intern_taks/Features/Notifications/local_notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'bottom_nav_bar_manager_screen/manager_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
  await LocalNotificationService.init();
  runApp(const RASIDTask());
}

class RASIDTask extends StatelessWidget {
  const RASIDTask({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue[50]),
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(providers: [
        BlocProvider(create: (context) => LocationCubit()),
      ], child: const ManagerScreen()),
    );
  }
}
