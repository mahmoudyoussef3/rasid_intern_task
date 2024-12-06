import 'package:flutter/material.dart';
import 'package:rasid_intern_taks/Features/Notifications/screens/notification.dart';
import 'package:rasid_intern_taks/Features/Portfolio/screen/portfolio.dart';
import '../Features/location/screen/location_screen.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  List<Widget> myScreens = [
    const PortfolioScreen(),
    LocationFetcherScreen(),
    const NotificationScreen()
  ];
  int _selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[800],
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.picture_as_pdf), label: 'Portfolio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined), label: 'Location'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_outlined),
              label: 'Notifications'),
        ],
        currentIndex: _selectedTab,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (value) {
          setState(() {
            _selectedTab = value;
          });
        },
      ),
      body: myScreens[_selectedTab],
    );
  }
}
