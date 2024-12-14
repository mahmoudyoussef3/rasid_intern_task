import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../local_notification_service.dart';

class BuildNotificationButton extends StatelessWidget {
  const BuildNotificationButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      required this.label,
      required this.id});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final int id;

  @override
  Widget build(BuildContext context) {
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
            LocalNotificationService().cancelNotification(id);
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
}
