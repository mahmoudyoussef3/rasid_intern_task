import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../local_notification_service.dart';

class BuildNotificationButton extends StatelessWidget {
  const BuildNotificationButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      required this.label,
      required this.color,
      required this.id});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final int id;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              Text(
                label,
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
