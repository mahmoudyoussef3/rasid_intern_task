import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildActionButton extends StatelessWidget {
  const BuildActionButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      required this.label});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xff4caf50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      onPressed: onPressed,
    );
  }
}
